
---
title: 如何将hexo的git pages项目部署vps？
date: 2018-03-29 13:56:11
tags: [列表,vps,git,配置]
categories: 配置
toc: true
mathjax: true
---
本文介绍如何在vps上搭建自己的blog。
<!-- more -->

## 环境
- digitalocean上ubuntu的vps一台
- window10+nodejs+hexo软件环境，参考[hexo搭建博客](https://leebin.top/2018/03/27/%E4%BD%BF%E7%94%A8github%20pages%E5%92%8Chexo%E6%90%AD%E5%BB%BA%E8%87%AA%E5%B7%B1%E7%9A%84%E5%8D%9A%E5%AE%A2/)

## 思路
- 方案一 vps上使用本地模式搭建hexo博客，使用Nginx将域名指向 http://localhost:4000
- 方案二 在客户端写blog，git推送到服务端，服务端用Nginx解析网页文件

## 过程
- 下文分为众多的详细步骤

### 安装git和nginx
- 安装软件git和nginx
```
apt-get update
apt-get install git
apt-get install nginx
```

### 配置git用户和仓库
- git用户权限设定（可以不需要）
```
chmod 740 /etc/sudoers
vim /etc/sudoers
#在root ALL=(ALL:ALL) ALL下面新增一行
git ALL=(ALL:ALL) ALL
chmod 440 /etc/sudoers
```
- 配置git用户和仓库, 参考[在vps上构建私有git服务器](https://leebin.top/2018/03/27/%E5%A6%82%E4%BD%95%E5%88%A9%E7%94%A8ubuntu%E5%AE%9E%E7%8E%B0%E7%A7%81%E6%9C%89git%E6%9C%8D%E5%8A%A1%E7%AB%AF-%E9%99%84ssh%E6%93%8D%E4%BD%9C%EF%BC%9F/)

### 配置git hooks
- 在hexo.git/hooks/目录下修改post-update.sample为post-update，并覆盖加入
```
#!/bin/bash
GIT_REPO=/home/git/hexo.git
TMP_GIT_CLONE=/tmp/hexo
PUBLIC_WWW=/var/www/hexo
rm -rf ${TMP_GIT_CLONE}
git clone $GIT_REPO $TMP_GIT_CLONE
rm -rf ${PUBLIC_WWW}/*
cp -rf ${TMP_GIT_CLONE}/* ${PUBLIC_WWW}
```
- 保证post-update有执行权限
```
chmod +x post-receive
```

### nginx配置
- 新建站点文件夹
```
mkdir -p /var/www/blog
chmod -R 775 /var/www/blog
chown -R git /var/www/blog
chgrp -R git /var/www/blog
```
- 配nginx的站点文件2处
```
vim /etc/nginx/conf.d/hexo.conf
server {
    listen  80 ;
    listen [::]:80;
    root /var/www/blog;
    server_name clearsky.me www.clearsky.me; #server_ip
    access_log  /var/log/nginx/hexo_access.log;
    error_log   /var/log/nginx/hexo_error.log;
    error_page 404 =  /404.html;
    location ~* ^.+\.(ico|gif|jpg|jpeg|png)$ {
        root /var/www/blog;
        access_log   off;
        expires      1d;
    }
    location ~* ^.+\.(css|js|txt|xml|swf|wav)$ {
        root /var/www/blog;
        access_log   off;
        expires      10m;
    }
    location / {
        root /var/www/blog;
        if (-f $request_filename) {
            rewrite ^/(.*)$  /$1 break;
        }
    }
    location /nginx_status {
        stub_status on;
        access_log off;
    }
}

vim /etc/nginx/sites-available/default
root /var/www/html;
```
- 重启nginx服务器
```
service nginx restart
#或者
/etc/init.d/nginx stop
/etc/init.d/nginx start
```
## 后续
- 修改本地的blog源文件，配置推送git服务器，推送到vps服务器上
- 参考[git pages多服务器部署](https://leebin.top/2018/03/29/git%20pages%E7%9A%84%E8%BF%81%E7%A7%BB%E5%92%8C%E5%A4%9A%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%83%A8%E7%BD%B2/)
