#!/bin/bash

sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release enable pxb-80
sudo yum install percona-xtrabackup-80
