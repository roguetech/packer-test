#!/bin/sh
#
#---------------------------
#variables
hidden_pw="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)"
now="$(date +"%m_%d_%y")"
logfile="/var/log/buildscript_${now}.log"
ethdev="$(ip -o link show | grep ens | awk -F': ' '{print $2}')"
pyver="12"
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
#Install parts
echo "Adding repos"
{
  yum -y install epel-release
}  &>> $logfile
task_end

echo "Installing Utils"
{
  yum -y install yum-utils bind-utils vim nano wget git curl gcc libxml2-devel.x86_64 libxslt-devel.x86_64 open-vm-tools.x86_64 firewalld openldap.x86_64 cloud-init
  yum -y upgrade
}  &>> /$logfile
task_end

echo "Configuring cloud-init"
{
  sed -i 's/^disable_root:.*/disable_root: 0/' /etc/cloud/cloud.cfg
  sed -i 's/^ssh_pwauth:.*/ssh_pwauth:   1/' /etc/cloud/cloud.cfg
}  &>> /$logfile
task_end

echo "Installing Python2.7-ALT + pip"
{
  cd /tmp
  yum -y groupinstall "Development Tools"
  yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
  wget http://python.org/ftp/python/2.7.$pyver/Python-2.7.$pyver.tar.xz
  tar xf Python-2.7.$pyver.tar.xz
  cd Python-2.7.$pyver
  ./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
  make && make altinstall
  wget https://bootstrap.pypa.io/ez_setup.py
  python2.7 ez_setup.py
  /usr/local/bin/easy_install-2.7 pip

}  &>> /$logfile
task_end

echo "Heat Config"
{
  yum -y install heat-cfntools
  pip install os-apply-config os-refresh-config os-collect-config
}  &>> $logfile
task_end

echo "Set persistent DHCP\DNS options"
{
  if grep "RES_OPTIONS" /etc/sysconfig/network; then
     sed -i 's/.*RES_OPTION.*/RES_OPTIONS="ndots:2 timeout:1"/' /etc/sysconfig/network
  else
     echo 'RES_OPTIONS="ndots:2 timeout:1"' >> /etc/sysconfig/network
  fi
} &>> $logfile
task_end

echo "Adding SSH config for root access"
{
  sed -i '/#PasswordAuthentication.*/d' /etc/ssh/sshd_config
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^.PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
}  &>> $logfile
task_end
