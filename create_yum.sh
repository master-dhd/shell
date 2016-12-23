#!/bin/bash
# 2016-11-2 by dhd version 1.1
# CentOS6.x 添加epel 、emi、rpmforge源
####################################################
# 2016-11-25 version 1.2 
# Add 163、rpmfusion-free-updates、atomic源
# Note : GW is 192.168.189.1
####################################################
# 2016-11-30 version 1.3
# Add Webtatic
# Usage：yum install package-name.version --enablerepo=webtatic-archive



#set -o nounset

. /etc/rc.d/init.d/functions

# 定义变量
RED_COLOR='\E[1;31m'   	#红
GREEN_COLOR='\E[1;32m' 	#绿
YELOW_COLOR='\E[1;33m' 	#黄
BLUE_COLOR='\E[1;34m'  	#蓝
PINK='\E[1;35m'       	#粉红
RES='\E[0m'
GW=www.hao123.com
NAME=`hostname`
FILE="/etc/yum.repos.d"
YUM="epel-release remi-release rpmforge-release rpmfusion-free-release"
DONE="\e[0;32m\032 OK \e[m"
ERRO="\e[0;31m\031 NO \e[m"

# 查看脚本说明
testFun(){
    head `pwd`/$0
    echo -e "${RED_COLOR} 此主机为：$NAME ${RES}"
    echo -e "${RED_COLOR} -------------------------------- ${RES}"
}

check_Fun(){
    [ $? -eq 0 ] && echo -e "${DONE}" || echo -e "${ERRO}"
}

# 安装
installFun(){
# 检测网络
    ping -c1 $GW &> /dev/null
    [ $? -ne 0 ] && echo -e "${RED_COLOR} 检查你的网络 ${RES}" && exit

# 安装第三方源
    # 163
    [ -f $FILE/CentOS6-Base-163.repo ] && echo -e "${GREEN_COLOR} 163已安装 ${RES}" ||
    wget -P $FILE http://mirrors.163.com/.help/CentOS6-Base-163.repo &> /dev/null ||
    mv $FILE/CentOS-Base.repo{,.bak}
	
	# atomic
	[ -f $FILE/atomic.repo ] && echo -e "${GREEN_COLOR} atomic已安装 ${RES}" ||
    wget -P /tmp http://www.atomicorp.com/installers/atomic &> /dev/null ||
    sh /tmp/atomic
	
	# Webtatic
	rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
	
    for RPM in $YUM
    do
        rpm -q $RPM &> /dev/null
        if [ $? -eq 0 ];then
	    echo -e "${GREEN_COLOR} 本机已经安装$RPM ${RES}" 
        else
            if [ "$RPM" = "epel-release" ];then
                rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 1> /dev/null
				#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 1> /dev/null
				check_Fun
				
            elif [ "$RPM" = "remi-release" ];then
                rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm 1> /dev/null
				#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi 1> /dev/null
				check_Fun
	        
			elif [ "$RPM" = "rpmforge-release" ];then
	            rpm -ivh ftp://195.220.108.108/linux/sourceforge/i/it/itmos/rely%20on%20cnz/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm 1> /dev/null
				check_Fun
	        
			elif [ "$RPM" = "rpmfusion-free" ];then
				rpm -ivh http://download1.rpmfusion.org/free/el/updates/6/x86_64/rpmfusion-free-release-6-1.noarch.rpm 1> /dev/null
				check_Fun
			
			fi
        fi
    done
    
# 安装yum优先级插件
    #yum install yum-priorities -y
	
# 修改优先级
    #sed -i '/\[base\]/a\priority=11' $FILE/CentOS6-Base-163.repo
    #sed -i '/\[epel\]/a\priority=12' $FILE/epel.repo
    #sed -i '/\[epel-testing\]/a\priority=22' $FILE/epel-testing.repo
    #sed -i '/\[remi\]/a\priority=13' $FILE/remi.repo
    #sed -i '/\[rpmforge\]/a\priority=14' $FILE/rpmforge.repo
    #sed -i '/\[rpmfusion-free-updates\]/a\priority=15' $FILE/rpmfusion-free-updates.repo
    #sed -i '/\[rpmfusion-free-updates-testing\]/a\priority=15' $FILE/rpmfusion-free-updates-testing.repo
    #sed -i '/\[atomic\]/a\priority=16' $FILE/atomic.repo
	
# 重建缓存
    echo -e "${GREEN_COLOR} 请等待建立缓存...... ${RES}"
	#yum clean all &> /dev/null
    yum makecache
    [ $? -eq 0 ] && echo -e "${GREEN_COLOR} 缓存成功 ${RES}"
	
# 升级
    echo -e "${GREEN_COLOR} 请等待升级...... ${RES}"
	yum install axel git yum-fastestmirror -y &> /dev/null
	cd /tmp
    git clone https://github.com/crook/yum-axelget &> /dev/null
	cp yum-axelget/axelget.conf /etc/yum/pluginconf.d/
    cp yum-axelget/axelget.py /usr/lib/yum-plugins/
	
    yum update -y
    [ $? -eq 0 ] && echo -e "${GREEN_COLOR} 升级成功 ${RES}"
}

# 交互输入
testFun
read -p "确定执行吗 [y/n]？" RE
case $RE in
    y | Y)
        echo -e "${RED_COLOR} 请等待...... ${RES}"
	    #yum groupinstall 'Development Tools' -y &> /dev/null
	    #mkdir /etc/yum.repos.d/centos
        #mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/centos
	    installFun
	;;
    n | N)
	    exit
	;;
    *)
	    echo -e "${RED_COLOR} 错误 ${RES}"
	    exit
esac