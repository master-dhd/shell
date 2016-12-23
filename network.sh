#!/bin/bash
# 2016年11月23日 by dhd
# OS centos 6.x
# For static ip & hostname & hosts & dns

# defining variable
Dev=$(ifconfig | sed -n '1p' | awk '{print $1}')
Netmask=$(ifconfig $Dev | sed -n '2p' | cut -d: -f4)
Ip=$(ifconfig $Dev | sed -n '2p'| cut -d: -f2 | cut -d" " -f1)
#Ip=$(ifconfig eth0 | sed -n '2p' | awk -F"[ :]+" '{print $4}')
Name=node$(echo $Ip | cut -d. -f4)
Hostname=$Name.test.com
Gateway=$(ip route show | grep "default" | awk '{print $3}')
Conf=/etc/sysconfig/network-scripts/ifcfg
Network_ser=/etc/init.d/network
Network_conf=/etc/sysconfig/network

# set static ip
echo -e "IPADDR=$Ip" >> $Conf-$Dev
echo -e "NETMASK=$Netmask" >> $Conf-$Dev
echo -e "GATEWAY=$Gateway" >> $Conf-$Dev
sed -i 's/BOOTPROTO=.*/BOOTPROTO=none/' $Conf-$Dev

#$Network_ser restart > /dev/null 2>&1
service network restart > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "\e[1;31m Your ip is $Ip \e[0m"
else
	echo -e "\e[1;41m Please check your network \e[0m"
	exit
fi
	
# set hosts
echo -e "$Ip\t$Hostname\t$Name" >> /etc/hosts

# set hostname
sed -i "s/HOS.*/HOSTNAME="$Hostname"/" $Network_conf
hostname $Hostname

# check hostname
ping -c1 $Hostname > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "\e[1;31m Your hostname is $Hostname \e[0m"
else

	echo -e "\e[1;41m Your hostname is ERRO \e[0m"
	exit
fi

# set dns
cat > /etc/resolv.conf <<EOF
search bj-office.eub-inc.com eub-inc.com
nameserver 211.167.230.100
nameserver 211.167.230.200
EOF