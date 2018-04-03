---
title: 如何利用ubuntu实现私有git服务端-附ssh操作？
date: 2018-03-27 11:00:00
tags:
	- git
	- 配置
	- 列表
categories: 配置
toc: true
mathjax: true
---

本文介绍如何利用云服务器实现私有git服务端，包含了git新建仓库、本地与服务器的ssh互连、保留gitlog迁移git的方法、以及创建仓库的自动化脚本。
<!-- more -->

## 在服务端下载git
- 下载安装git
```
apt-get update
apt-get install git -y
```

## 配置git用户
- 添加git用户
```
useradd git
passwd git
```

## 通过ssh客户端和服务器互连
- 客户端生成ssh密钥
```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub注册邮箱"
ssh-keygen -t rsa -C "你的GitHub注册邮箱"
cat ~/.ssh/id_rsa.pub
```
- 或者 上述操作可以集成为无交互的脚本在本地直接执行即可
```bash
y=$(date +%y)
m=$(date +%m)
d=$(date +%d)
H=$(date +%H)
M=$(date +%M)
S=$(date +%S)
path=$(pwd)
cd ~
git config --global user.name "bin_lee"
git config --global user.email "xjd.binlee@qq.com"
#cd ~/.ssh
tar -zcvf ssh_binlee_backup_$y-$m-$d-$H-$M-$S.tar.gz .ssh
rm -rfd ~/.ssh
# ssh-keygen -t rsa -C "xjd.binlee@qq.com"
ssh-keygen -t rsa -P "" -C "xjd.binlee@qq.com" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub
cd $path
```
- 服务端安装ssh并实现xshell连接
```bash
#安装
sudo apt-get install openssh-server -y
sudo ps -e |grep ssh
sudo service ssh start
sudo passwd root
sudo vi /etc/ssh/sshd_config
PermitRootLogin prohibit-password
PermitRootLogin yes
sudo service ssh restart
#在服务器的指定用户目录下
mkdir -p /root/.ssh
touch authorized_keys
```

- 将上述生成的密钥文件添加到服务端
```bash
echo "密钥" >> /root/.ssh/authorized_keys
```
- 客户端测试连通性
```bash
ssh -T git@gitee.com
或者
ssh -T git@server_ip
```

## 新建git仓库并使用
- 新建git仓库
```
mkdir -p /srv/git/repos/xxx.git
cd /srv/git/repos
```
- 初始化git仓库
```
git init --bare /srv/git/repos/xxx.git
```
- 设置git仓库的访问权限
```bash
cd /srv/git/repos
chmod -R 775 xxx.git
chown -R git xxx.git
chgrp -R git xxx.git
```
- 克隆git仓库并测试
```bash
git clone git@server_ip:/srv/git/repos/xxx.git
```
## 大招 将上述操作合并为git脚本
```bash
apt-get update
echo "----------------------------------------"
echo ">>> update finished..."
echo "----------------------------------------"
apt-get install git -y
echo "----------------------------------------"
echo ">>> install finished..."
echo "----------------------------------------"
#useradd git
#passwd git
#or
#openssl passwd -stdin
useradd -p "8iENHwQTXrdZM" git
#change passwd
touch chpass.txt
echo "git:hest" >> chpass.txt
chpasswd < chpass.txt
rm -rf chpass.txt
echo "----------------------------------------"
echo ">>> useradd and reset passwd finished..."
echo "----------------------------------------"
key="ssh-rsa AAA......."
mkdir -p /home/git/.ssh
touch /home/git/.ssh/authorized_keys
#vim /home/git/.ssh/authorized_keys
echo "${key}" >> /home/git/.ssh/authorized_keys
cat /home/git/.ssh/authorized_keys
echo "----------------------------------------"
echo ">>> add authorized_keys finished..."
echo "----------------------------------------"
respos_path="/srv/git/respos/"
project_name="test.git"
project_path=${respos_path}${project_name}
mkdir -p ${project_path}
git init --bare ${project_path}
chmod -R 775 ${project_path}
chown -R git ${project_path}
chgrp -R git ${project_path}
echo "----------------------------------------"
echo "init git respos finished..."
my_ip=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
echo "git clone git@${my_ip}:${project_path}"
echo "----------------------------------------"
```
## 如果出错销毁服务端git
```
userdel -r git
rm -rdf /srv/git/
```
## 如果服务器出现问题，保留gitlog迁移git的方法
```bash
#在源服务器上裸克隆
git clone --bare git://github.com/username/project.git
cd project.git
#镜像上传到新的服务器上
git push --mirror git@gitcafe.com/username/newproject.git
cd ..
rm -rf project.git
#克隆新服务器下的工程到客户端
git clone git@gitcafe.com/username/newproject.git
#设置新的上传url为新服务器的地址
git remote set-url origin remote_git_address  
```
