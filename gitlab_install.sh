#!/bin/bash
# 2016-11-30 by dhd
# For gitlab install
# 注意内存最少4G：
# 4GB RAM is the recommended memory size for all installations and supports up to 100 users


# centos 7
# https://about.gitlab.com/downloads/#centos7
# 1. 
yum install curl policycoreutils openssh-server openssh-clients lokkit
systemctl enable sshd
systemctl start sshd
yum install postfix
systemctl enable postfix
systemctl start postfix
firewall-cmd --permanent --add-service=http
#systemctl reload firewalld

# 2.
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
yum install gitlab-ce-8.14.1-ce.1.el7.x86_64

# 3.
gitlab-ctl reconfigure
echo "waite for about 10 min"

# 4. Browse to the hostname and login

#######################################################################
# centos 6.x
# https://about.gitlab.com/downloads/#centos6
# 1. Install and configure the necessary dependencies
yum -y install curl openssh-server openssh-clients postfix cronie lokkit
service postfix start
chkconfig postfix on

# for iptables
#lokkit -s http -s ssh

# 2. Add the GitLab package server and install the package
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
ls /etc/yum.repos.d/gitlab_gitlab-ce.repo
yum -y install gitlab-ce

#If you are not comfortable installing the repository through a piped script, 
#you can find the entire script here and select and download the package manually and install using
#curl -LjO https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/6/gitlab-ce-XXX.rpm/download
#rpm -i gitlab-ce-XXX.rpm

# 3. Configure and start GitLab
gitlab-ctl reconfigure

# 4. Browse to the hostname and login
# http://IP