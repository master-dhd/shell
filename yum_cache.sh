#!/bin/bash
# 2016-12-21 by dhd
# For yum cache rpm
# Note:
# Change the cache dir & save dir

# Define variable
RPM="php56"
CONF="/etc/yum.conf"
C_DIR="/var/cache/yum/$RPM"
S_DIR="/root/RPM/$RPM"

# mkdir
mkdir $C_DIR
mkdir -p $S_DIR
cp $CONF{,.bak}

# enable cache
sed -i "s/keepcache=0/keepcache=1/" $CONF
sed -i "s#cachedir.*#cachedor=$C_DIR#" $CONF

# createrepo
yum -y install createrepo
cd S_DIR
createrepo .

# create yum repo
cat << EOF > /etc/yum.repos.d/php56.repo
[$RPM]
name=$RPM
baseurl=file://$S_DIR
enable=1
gpgcheck=0

EOF

# install
#yum -y install

# mv rpm from cache dir to save dir
#for i in `ls $C_DIR | grep -v timedhosts.txt` ; do mv $C_DIR/$i/packages/* $S_DIR; done

#
#yum localinstall *
