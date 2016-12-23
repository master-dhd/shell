#!/bin/bash
# 2016-12-20 by dhd
#开发机升级 php5.4到php 5.6 及安装 oci 支持的方法

# 1. 修改 /etc/yum.repos.d/remi.repo , 将 remi-php56 打开


# 2. 安装 Oracle 驱动
cd temp/
wget http://templates.bj-office.eub-inc.com/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
echo "/usr/lib/oracle/12.1/client64/lib" > /etc/ld.so.conf.d/oracle-x86_64.conf
ldconfig
echo $?

# 3. 卸载旧的 php 5.4
yum remove -y php-*

# 4. 安装 php 5.6
yum install -y php-cli php-fpm php-pdo php-pear php-fpm php-gd php-imap php-mbstring php-mcrypt php-mongodb php-mysqlnd php-oci8 php-pdo php-pecl-imagick php-redis php-memcached php-snmp php-soap php-xml php-process

# 5. 解决FPM报错
cat >> /etc/sysconfig/php-fpm<<EOF
ORACLE_HOME=/usr/lib/oracle/12.1/client64
LD_LIBRARY_PATH=$ORACLE_HOME/lib
NLS_LANG=AMERICAN_AMERICA.UTF8
export ORACLE_HOME LD_LIBRARY_PATH NLS_LANG
EOF

/etc/init.d/php-fpm restart