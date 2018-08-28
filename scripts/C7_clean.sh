#!/bin/sh
#
#---------------------------
#variables
now="$(date +"%m-%d-%y")"
logfile="/var/log/cleanscript_${now}.log"
ethdev="$(ip -o link show | grep -v LOOPBACK | awk -F': ' '{print $2}')"
pyver="10"
cloudconf="/etc/cloud/cloud.cfg"
#----------------------------
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
#----------------------------
#Cleanup
echo "Stop Logging"
{
  service rsyslog stop
  service auditd stop
} &>> $logfile
task_end

echo "Truncate Logs"
{
  rm -rf cron-*
  rm -rf /var/log/anaconda*
  rm -rf /var/log/dmesg.*
  rm -rf /var/log/dracut.*
  rm -rf /var/log/maillog-*
  rm -rf /var/log/messages-*
  rm -rf /var/log/secure-*
  rm -rf /var/log/spooler-*
  rm -rf /var/log/btmp-*
  rm -rf /var/log/vmware-install.log
  rm -rf /var/log/vmware-tools-upgrader.log
  rm -rf /var/log/wtmp-*
  rm -rf /var/log/yum.log-*
  rm -rf /var/log/cloud-init.log
  rm -rf /var/log/cloud-init-output.log
  cat /dev/null > /var/log/cron
  cat /dev/null > /var/log/dmesg
  cat /dev/null > /var/log/dracut
  cat /dev/null > /var/log/messages
  cat /dev/null > /var/log/secure
  cat /dev/null > /var/log/spooler
  cat /dev/null > /var/log/yum.log
  cat /dev/null > /var/log/vmware-vmsvc.log
  cat /dev/null > /var/log/audit/audit.log
  cat /dev/null > /var/log/wtmp
  cat /dev/null > /var/log/lastlog
  cat /dev/null > /var/log/grubby
  cat /dev/null > /var/log/btmpk
} &>> $logfile
task_end

echo "Cleanup uDev"
{
  rm -f /etc/udev/rules.d/90-eno-fix*
} &>> $logfile
task_end

echo "Package Cleanup"
{
  yum -y remove epel-release git zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libxml2-devel.x86_64 libxslt-devel.x86_64 git postfix
  package-cleanup --oldkernels --count=1
  yum clean all
} &>> $logfile
task_end

echo "Remove other ens160 interfaces"
{
  for interface in $(ls -1 /etc/sysconfig/network-scripts/ifcfg-ens160?)
  do
    rm -f ${interface} 
  done
} &>> $logfile
task_end

echo "Remove MAC"
{
  sed -ie '/UUID\|HWADDR\|IPV6*/d' /etc/sysconfig/network-scripts/ifcfg-$ethdev
} &>> $logfile
task_end

echo "Removing Host Keys"
{
  rm -rf /etc/ssh/*key*
  rm -f /root/.ssh/
  rm -f /root/anaconda-ks.cfg
  rm -f /root/original-ks.cfg
} &>> $logfile
task_end

echo "Cleanup /tmp"
{
  rm -rf /tmp/*
  rm -rf /var/tmp/*
} &>> $logfile
task_end

echo "Remove History & Junk"
{
  cat /dev/null > ~/.bash_history && history -c && history -w
  rm -f $HISTFILE
} &>> $logfile
task_end

echo "Clean Cache"
{
  sync; echo 3 > /proc/sys/vm/drop_caches
} &>> $logfile
task_end

cat <<EOM >>$logfile
This template was closed:
${now}
EOM
