#!/bin/bash
# 2016-07-12 by dhd
# 1. Create ssh-keygen
# 2. Scp authorized_keys and hosts
# 3. Change hostname
# Note
# Check your yum
#############################################################
# 2016-11-14 version2.0

# define variable
PASS="123456"
KEY="/root/.ssh/id_rsa"
NAME="test.com"
HOSTS="/etc/hosts"
NETWORK="/etc/sysconfig/network"
L_IP=`ifconfig eth0 | sed -n '2p'| cut -d: -f2 | cut -d" " -f1`

# hosts
for i in 29 30 31 33 35; do echo -e "192.168.189.$i\tnode$i.$NAME\tnode$i" >> $HOSTS; done

# change local hostname
L_NAME=`cat $HOSTS | grep ^$L_IP | awk '{print $2}'`
sed -i "s/^HOS.*/HOSTNAME=$L_NAME" $NETWORK; hostname $L_NAME
unset i

# check expect
rpm -q expect &> /dev/null
if [ $? != 0 ];then
    yum repolist &> /dev/null
	[ $? -eq 0 ] && yum install expect -y ||
	echo -e "check your yum" && exit
fi

# ssh-keygen
if [ ! -f $KEY ];then
/usr/bin/expect <<END
spawn ssh-keygen -b 1024 -t rsa
expect "*id_rsa*"
send "\r"
expect "*passphrase):"
send "\r"
expect "*again:"
send "\r"
expect eof
END

fi

# ssh-copy-id
for DIP in `cat /etc/hosts |grep -v $L_IP | awk 'NR>2 {print $1}' | grep -v ^#`
do
#dip=192.168.122.90
expect -c "
set timeout -1
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $DIP
expect {
	\"*yes/no*\" {exp_send \"yes\r\"; exp_continue}
	\"*password:\" {send \"$PASS\r\"}
	}
expect eof"

D_NAME=`grep ^$DIP /etc/hosts | awk '{print $2}'`
ssh $DIP "sed -i "s/^HOS.*/HOSTNAME=$D_NAME/" $NETWORK"
ssh $DIP "hostname $D_NAME"
ssh $DIP "cp $HOSTS{,.bak}"
scp $HOSTS "$DIP:/etc"

done
