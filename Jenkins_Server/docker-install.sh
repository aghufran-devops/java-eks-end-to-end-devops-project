#!/bin/bash
# install Docker
yum update
yum install docker -y
systemctl enable docker
systemctl start docker
useradd dockeradmin
usermod -aG docker dockeradmin
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd