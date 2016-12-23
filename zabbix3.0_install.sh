#!/bin/bash
# 2016-12-1 by dhd vsersion 1.1
#####################################################################################
# 系统版本：CentOS Linux release 7.2.1511 (Core)
# 内核版本：3.10.0-327.el7.x86_64
# Httpd版本：2.4.6-40.el7.centos
# MariaDB版本：5.5.47-1.el7_2
# PHP版本：5.4.16-36.el7_1
#####################################################################################

# 初始环境调整
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

ping -c1 www.126.com &> /dev/null
[ $? -ne 0 ] && echo "Please check your network!!!"

yum install epel-release.noarch wget vim gcc gcc-c++ lsof chrony tree nmap unzip rsync -y
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

# LAMP环境部署
yum install httpd mariadb mariadb-server mariadb-client php php-mysql unixODBC -y

systemctl start mariadb
systemctl restart mariadb

# MariaDB数据库安全调整
#mysql -e "DELETE FROM mysql.user WHERE User=''"
#mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
#mysql -e "DROP DATABASE test;"
#mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
#mysql -e "FLUSH PRIVILEGES"

# 创建Zabbix服务端的数据库和使用的账号
mysql -e "CREATE DATABASE zabbix DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;"
mysql -e "GRANT ALL ON zabbix.* TO 'zabbix'@'%' IDENTIFIED BY 'zabbix';"
mysql -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';"
mysql -e "flush privileges"

# Zabbix应用部署
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-agent-3.0.0-1.el7.x86_64.rpm
yum install zabbix-server-mysql zabbix-web-mysql zabbix-get zabbix-agent -y

# 导入Zabbix服务端的表结构
cd /usr/share/doc/zabbix-server-mysql*/
zcat create.sql.gz | mysql -uroot zabbix
cd

sed -i 's/^;date.timezone =/date.timezone = Asia\/Shanghai/' /etc/php.ini
sed -i '/^# DBPassword=/a \\nDBPassword=zabbix' /etc/zabbix/zabbix_server.conf
sed -i 's@# \(php_value date.timezone \).*@\1Asia/Shanghai@' /etc/httpd/conf.d/zabbix.conf

systemctl restart mariadb

systemctl restart httpd
systemctl restart zabbix-agent
systemctl restart zabbix-server

systemctl enable httpd
systemctl enable mariadb 
systemctl enable zabbix-server
systemctl enable zabbix-agent

chkconfig zabbix-agent on
chkconfig zabbix-server on

lsof -i:10051 
if [ $? -eq 0 ];then
echo "**************************************************************"
echo "* Note: 1. Continuing install Zabbix on web http://IP/zabbix *" 
echo "*       2. Database User:zbbix Password:zabbix               *"
echo "*       3. index.php username:admin password:zabbix          *"
echo "**************************************************************"
fi