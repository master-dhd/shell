#!/bin/bash
# For install ansible source code
# python 2.7

git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible

# use bash
source ./hacking/env-setu

#If you want to suppress spurious warnings/errors, use:
source ./hacking/env-setup -q

# install pip
easy_install pip
pip install paramiko PyYAML Jinja2 httplib2 six

#
make install

#
#for i in {51..61};do echo 192.168.188.$i >> ~/ansible_hosts ; done
#export ANSIBLE_HOSTS=~/ansible_hosts
mkdir /etc/ansible
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOSTS=/etc/ansible/hosts
#echo -e "[dev]\ndev[01:11].bj-office.eub-inc.com" >> /etc/ansible/hosts

# test
#ansible all -m ping