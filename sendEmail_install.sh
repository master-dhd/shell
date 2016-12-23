#!/bin/bash
# 2016-12-05 by dhd
# For install sendEmail for zabbix-server
#

#
cd /tmp
wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
tar zxf sendEmail-v1.56.tar.gz -C /usr/src
cd /usr/src/sendEmail-v1.56/
cp -a sendEmail /usr/local/bin
chmod +x /usr/local/bin/sendEmail

#
yum install perl-Net-SSLeay perl-IO-Socket-SSL -y

#grep "alertscripts" /etc/zabbix/zabbix_server.conf
cd /usr/lib/zabbix/alertscripts
# 注意""相当于强引用
cat << "EOF" > sendEmail.sh
#!/bin/bash

MAIL="zabbix_server200@163.com"
SMTP="smtp.163.com"
PASS="rbcjk8312"

to=$1
subject=$2
body=$3

/usr/local/bin/sendEmail -f $MAIL -t "$to" -s $SMTP -u "$subject" -o message-content-type=html -o message-charset=utf8 -xu $MAIL -xp $PASS -m "$body"

EOF

chmod +x sendEmail.sh
chown zabbix.zabbix sendEmail.sh

#/etc/init.d/zabbix-server restart
