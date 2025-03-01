#!/bin/bash

set -e

repo_rpm_url="https://repo.mysql.com/mysql80-community-release-el8.rpm"
repo_rpm_filename=$( basename "$repo_rpm_url" )
rpm_gpg_key="https://repo.mysql.com/RPM-GPG-KEY-mysql-2023"

# 临时密码
mysql_root_password=$( grep -i "A temporary password is generated" /var/log/mysqld.log | awk '{ print $NF }' )
new_root_password="Admin@1209"

# 是否已经下载了 rpm 文件
if [ ! -e "$repo_rpm_filename" ]; then
   wget "$repo_rpm_url" || { echo "下载 $repo_rpm_filename 失败"; exit 1; }
fi

sudo yum module -y disable mysql
sudo rpm -ivh "$repo_rpm_filename"
sudo rpm --import "$rpm_gpg_key"

sudo yum install -y mysql-community-server
sudo systemctl enable mysqld.service
sudo systemctl start mysqld.service

# 修改 root 密码
mysqladmin -uroot -p"$mysql_root_password" password "$new_root_password" 2> /dev/null

if mysql -uroot -p"$new_root_password" -e "SHOW DATABASES" &> /dev/null; then
   echo "成功修改root密码！"
fi
