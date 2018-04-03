---
title: 如何利用VPS搭建自己的ss服务器？
date: 2018-03-27 10:00:00
tags:
	- ss
	- 配置
	- 列表
categories: 配置
toc: true
mathjax: true
---

本文描述了如何在ubuntu服务器上快速搭建自己的shadowcoks代理服务器。
<!-- more -->


## 以详细步骤安装配置启动过程
### 1.安装ss
```bash
apt-get update
sudo apt-get install python-pip -y
sudo pip install shadowsocks
```

### 2.配置
```bash
mkdir /etc/shadowsocks
touch /etc/shadowsocks/ss_config.json
vim /etc/shadowsocks/ss_config.json
{
  "server": "165.227.213.57",
  "port_password": {
      "10001": "112345678a!",
      "10002": "112345678a!",
      "10003": "112345678a!"
  },
  "local_port": 1080,
  "timeout": 600,
  "method": "aes-256-cfb"
}
```
### 3.启动
```bash
cd ~
touch start.sh
chmod 775 start.sh
vim start.sh

ssserver -c /etc/shadowsocks/ss_config.json -d start
ssserver -c /etc/shadowsocks/ss_config_multiple.json -d start
netstat -ntlp | grep python

touch stop.sh
chmod 775 stop.sh
vim stop.sh

ssserver -c /etc/shadowsocks/ss_config.json -d stop
ssserver -c /etc/shadowsocks/ss_config_multiple.json -d stop
netstat -ntlp | grep python
```
## 用脚本实现一键安装
### 1.创建配置启动脚本
```bash
创建x脚本
touch x && chmod 775 x && vim x
直接复制到x脚本里面
cd ~ && touch ss_cfg.json
ip="162.243.161.150"
echo "{" >> ss_cfg.json
echo "\"server\": \"${ip}\"," >> ss_cfg.json
echo "\"port_password\": {" >> ss_cfg.json
echo "\"10001\": \"helloworld\"," >> ss_cfg.json
echo "\"10002\": \"helloworld\"," >> ss_cfg.json
echo "\"10003\": \"helloworld\"" >> ss_cfg.json
echo "}," >> ss_cfg.json
echo "\"local_port\": 1080," >> ss_cfg.json
echo "\"timeout\": 600," >> ss_cfg.json
echo "\"method\": \"aes-256-cfb\"" >> ss_cfg.json
echo "}" >> ss_cfg.json
cd ~
touch sta.sh && chmod 775 sta.sh
echo "ssserver -c ~/ss_cfg.json -d start" >> ~/sta.sh
echo "netstat -ntlp | grep python" >> ~/sta.sh
touch sto.sh && chmod 775 sto.sh
echo "ssserver -c ~/ss_cfg.json -d stop" >> ~/sto.sh
echo "netstat -ntlp | grep python" >> ~/sto.sh
echo "-------------report-------------------"
echo "the fie list as follows:"
ls
echo "-------------start ss-----------------"
./sta.sh
echo "-------------your ss config-----------"
echo "ip=${ip}"
echo "port=10001, password=helloworld"
echo "port=10002, password=helloworld"
echo "port=10003, password=helloworld"
echo "local_port=1080"
echo "timeout=600"
echo "method=aes-256-cfb"
echo "-------------end---------------------"
```
### 2.启动服务
```bash
运行x脚本
./x
启动服务
./sta.sh
关闭服务
./sto.sh
删除文件
rm -rf x ss_cfg.json sta.sh sto.sh && touch x && chmod 775 x && vim x
```
