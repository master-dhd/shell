#!/bin/bash
# 2016-12-1 by dhd
# For zabbix agent
# OS；centos 7.x & centos6.x

# Note: 
# 1. Change server IP
# 2. Add the agent hostname in server hosts
#######################################################################################################
SERVER_IP=192.168.189.34
CONF=/etc/zabbix/zabbix_agentd.conf

set_base_Fun{
ping -c1 www.126.com &> /dev/null
if [ $? -ne 0 ];then
    echo "Please check your network!!!" && exit
else
    rpm -q zabbix-agent &> /dev/null
	if [ $? -eq 0 ];then
        echo "zabbix-agent is on you system !!!" && exit
	else
	    setenforce 0
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
        yum -y install unixODBC
	fi
fi
}

change_conf_Fun{
cp $CONF{,.bak}
sed -i "s/^Server=.*/Server=$SERVER_IP/" $CONF
sed -i "s/^ServerActive=.*/ServerActive=$SERVER_IP/" $CONF
sed -i "s/^Hostname=.*/Hostname=`hostname`/" $CONF
}

install_el6_Fun{
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.0-2.el6.x86_64.rpm
change_conf_Fun
/etc/init.d/zabbix-agent start
chkconfig zabbix-agent on
}

install_el7_Fun{
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-agent-3.0.0-1.el7.x86_64.rpm
change_conf_Fun
systemctl start zabbix-agent
systemctl enable zabbix-agent
}

check_status_Fun{
ps aux | grep zabbix_agentd | grep -v grep
}

set_base_Fun
uname -r | grep el6
if [ $? -eq 0 ];then
    install_el6_Fun
else
    uname -r | grep el7
    if [ $? -eq 0 ];then
	    install_el7_Fun
	else
		echo "Unknow system !!!" && exit
    fi
fi