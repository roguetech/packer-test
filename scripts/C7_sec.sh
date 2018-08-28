#!/bin/sh
#----------------------------
#variables
logfile="/var/log/sec.log"
#functions
task_end()
{
if [ $? -eq 0 ]
then
    echo "Done :-)"
else
    echo "Failed :-("
    tail $logfile
    exit 1
fi
}

#System hardening
echo "Legal banners"
{
cat <<EOM >/etc/motd

        This system is for authorised Global Payments users only. Any individual using
        this computer system are subject to having any or all of their activities on
        this system recorded and stored by sanctioned system personnel. By using this
        system the individual gives express consent to such monitoring and if in the
        course of such monitoring activities reveals possible evidence of criminal
        activity, system personnel may provide this evidence to law enforcement
        officials.
        ******Note there is no expectation of privacy on this system ******

EOM

cat <<EOM >/etc/issue.net
        This system is for authorised Global Payments users only. Any individual using
        this computer system are subject to having any or all of their activities on
        this system recorded and stored by sanctioned system personnel. By using this
        system the individual gives express consent to such monitoring and if in the
        course of such monitoring activities reveals possible evidence of criminal
        activity, system personnel may provide this evidence to law enforcement
        officials.
        ******Note there is no expectation of privacy on this system ******
EOM
}  &>> $logfile
task_end

echo " Remove unwanted user & groups"
{
  userdel lp
  userdel ftp
  userdel chrony
  userdel games
  groupdel ftp
  groupdel tape
  groupdel chrony
  groupdel floppy
  groupdel games
} &>> $logfile



echo Configure Login.defs
{
  sed -i "s/.*PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/" /etc/login.defs
  sed -i "s/.*PASS_MAX_DAYS.*/PASS_MAX_DAYS 60/" /etc/login.defs
  sed -i "s/.*PASS_MAX_DAYS.*/PASS_MIN_LEN 14/" /etc/login.defs
} &>> $logfile
task_end

echo "Fix fstab"
{
  sed -ie '/^\/dev\/mapper\/vg00-lv_tmp/ s/defaults/defaults,nosuid,noexec,nodev/' /etc/fstab
  sed -ie '/^\/dev\/mapper\/vg00-lv_var/ s/defaults/defaults,nosuid/' /etc/fstab
  sed -ie '/^\/dev\/mapper\/vg00-lv_home/ s/defaults/defaults,nodev/' /etc/fstab
  echo "/tmp /var/tmp none rw,noexec,nosuid,nodev,bind 0 0" >> /etc/fstab
  mount -a
} &>> $logfile
task_end

echo "Remove unwanted software"
{
  yum -y remove 'iwl*firmware*'
  yum -y remove gdb
} &>> $logfile
task_end

echo " Configure sysconfig/network"
{
  if grep "NOZEROCONF" /etc/sysconfig/network; then
     sed -i "s/.*NOZEROCONF.*/NOZEROCONF=yes/" /etc/sysconfig/network
  else
     echo "NOZEROCONF=yes" >> /etc/sysconfig/network
  fi
  if grep "NETWORKING_IPV6" /etc/sysconfig/network; then
     sed -i "s/.*NETWORKING_IPV6.*/NETWORKING_IPV6=no/" /etc/sysconfig/network
  else
     echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
  fi
  if grep "IPV6INIT" /etc/sysconfig/network; then
     sed -i "s/.*IPV6INIT.*/IPV6INIT=no/" /etc/sysconfig/network
  else
     echo "IPV6INIT=no" >> /etc/sysconfig/network
  fi
} &>> $logfile
task_end

echo Set profile
{
  sed -i "s/.*umask 022.*/umask 027/" /etc/profile
  sed -i "s/.*umask 002.*/umask 027/" /etc/profile
} &>> $logfile
task_end

echo "Disable unwanted modules"
{
  rm -rf /lib/modules/$(uname -r)/kernel/drivers/firewire
  rm -rf /lib/modules/$(uname -r)/kernel/drivers/isdn
  rm -rf /lib/modules/$(uname -r)/kernel/drivers/infiniband
  rm -rf /lib/modules/$(uname -r)/kernel/drivers/bluetooth
  rm -rf /lib/modules/$(uname -r)/kernel/drivers/pcmcia
  echo "blacklist firewire-core" > /etc/modprobe.d/blacklist-firewire.core
  echo "install usb-storage /bin/false" > /etc/modprobe.d/no-usb-storage.conf
  echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
  echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
  echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
  echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf
  echo "options ipv6 disbale=1" > /etc/modprobe.d/disabled.conf
  echo "install cramfs /bin/false" > /etc/modprobe.d/cramfs.conf
  echo "install freevxfs /bin/false" > /etc/modprobe.d/freevxfs.conf
  echo "install jffs2 /bin/false" > /etc/modprobe.d/jffs2.conf
  echo "install hfs /bin/false" > /etc/modprobe.d/hfs.conf
  echo "install hfsplus /bin/false" > /etc/modprobe.d/hfsplus.conf
  echo "install squashfs /bin/false" > /etc/modprobe.d/squashfs.conf
  echo "install udf /bin/false" > /etc/modprobe.d/udf.conf
} &>> $logfile
task_end

echo "profile"
{
  cat <<EOM > //etc/profile.d/rxp.sh
  function log2syslog
  {
  declare COMMAND
  COMMAND=$(fc -ln -0 2>/dev/null)
  logger -p local1.notice -t bash -i – "${USER}:${COMMAND}"
  }
  trap log2syslog DEBUG
  readonly HISTFILE
  readonly TMOUT=900
EOM
  chmod +x /etc/profile.d/rxp.sh
}
&>> $logfile
task_end

echo "Securing Cron"
{
  touch /etc/cron.allow
  chmod 600 /etc/cron.allow
  awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
  touch /etc/at.allow
  chmod 600 /etc/at.allow
  awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/at.deny
} &>> $logfile
task_end


echo "Configure SSHD"
{
  sed -i "s/.*AllowTcpForwarding.*/AllowTcpForwarding no/" /etc/ssh/sshd_config
  sed -i "s/.*ClientAliveCountMax.*/ClientAliveCountMax 2/" /etc/ssh/sshd_config
  sed -i "s/.*Compression.*/Compression no/" /etc/ssh/sshd_config
  sed -i "s/.*LogLevel.*/LogLevel INFO/" /etc/ssh/sshd_config
  sed -i "s/.*MaxAuthTries.*/MaxAuthTries 1/" /etc/ssh/sshd_config
  sed -i "s/.*MaxSessions.*/MaxSessions 2/" /etc/ssh/sshd_config
  sed -i "s/.*TCPKeepAlive.*/TCPKeepAlive no/" /etc/ssh/sshd_config
  sed -i "s/.*UsePrivilegeSeparation.*/UsePrivilegeSeparation sandbox/" /etc/ssh/sshd_config
  sed -i "s/.*X11Forwarding.*/X11Forwarding no/" /etc/ssh/sshd_config
  sed -i "s/.*AllowAgentForwarding.*/AllowAgentForwarding no/" /etc/ssh/sshd_config
  sed -i "s/.*UseDNS.*/UseDNS no/" /etc/ssh/sshd_config
  sed -i "s/.*ClientAliveInterval.*/ClientAliveInterval 300/" /etc/ssh/sshd_config
  sed -i "s/.*Banner.*/Banner /etc/motd/" /etc/ssh/sshd_config
  sed -i "s/.*PermitEmptyPasswords.*/PermitEmptyPasswords no/" /etc/ssh/sshd_config
  if grep "MACs" /etc/ssh/sshd_config; then
     sed -i "s/.*MACs.*/MACs hmac-sha1,hmac-ripemd160/" /etc/ssh/sshd_config
  else
     echo
     echo "MACs hmac-sha1,hmac-ripemd160" >> /etc/ssh/sshd_config
  fi

  if grep "Ciphers" /etc/ssh/sshd_config; then
     sed -i "s/.*Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/" /etc/ssh/sshd_config
  else
     echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
  fi
}  &>> $logfile
task_end

echo "Configuring Sysctl params"
{
cat <<EOM > /etc/sysctl.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.exec-shield = 1
kernel.randomize_va_space = 1
EOM
} &>> $logfile
task_end

echo "Set Sticky bit"
{
  find . -perm -o+w -exec chmod +t {} +
} &>> $logfile
task_end


echo "Deny TCP wrappers"
{
  echo "ALL:ALL" >> /etc/hosts.deny
  echo "sshd:ALL" >> /etc/hosts.allow
} &>> $logfile
task_end

echo "Disable network Manager"
{
  service NetworkManager stop
  chkconfig NetworkManager off
  service network start
  chkconfig network on
  yum -y remove NetworkManager
} &>> $logfile
task_end


#------------------------------------------
