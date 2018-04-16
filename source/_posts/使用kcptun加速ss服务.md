
---
title: 使用kcptun加速ss服务
date: 2018-04-15 23:55:21
tags: [列表,配置,kcptun,ss]
categories: 配置
toc: true
mathjax: true
---
本文介绍如何使用kcptun加速ss服务。
<!-- more -->

## 软件准备
- 安装组件
```
apt-get update
apt-get upgrade
apt-get install build-essential python-pip m2crypto supervisor
```
- 安装ss
```
pip install shadowsocks
```
- 安装加密用软件 libsodium
```
wget https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz
tar zxvf libsodium-1.0.11.tar.gz
cd libsodium-1.0.11
./configure
make && make check
make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig
```
- [可选] 配置supervisor, vi /etc/supervisor/conf.d/shadowsocks.conf
```
[program:shadowsocks]
command=ssserver -c /etc/shadowsocks.json
autorestart=true
user=root
```

- [可选] 使用supervisor
```
supervisorctl reload
supervisorctl status
```

## ss配置
- ss服务器配置ss_config.json
```
{
"server": "127.0.0.1",
"port_password": {
"10001": "helloworld",
"10002": "helloworld",
"10003": "helloworld"
},
"local_port": 1080,
"timeout": 600,
"method": "chacha20",
"auth": true
}
```
- 启动和停止脚本
```
ssserver -c /root/shadowsocks/ss_config.json -d start
ssserver -c /root/shadowsocks/ss_config.json -d stop
```


## kcptun配置
- kcptun官网 https://github.com/xtaci/kcptun/releases
- 其中 kcptun-linux-amd64-20180316.tar.gz 为Linux版本
- 其中 kcptun-windows-amd64-20180316.tar.gz 为Windows版本
- 安装 kcptun
```
mkdir /root/kcptun
cd /root/kcptun
ln -sf /bin/bash /bin/sh
wget https://github.com/xtaci/kcptun/releases/download/v20161118/kcptun-linux-amd64-20161118.tar.gz
tar -zxf kcptun-linux-amd64-*.tar.gz
```
- 配置三个脚本start.sh, stop.sh, server-config.json

1. 启动脚本vi /root/kcptun/start.sh
```
#!/bin/bash
cd /root/kcptun/
./server_linux_amd64 -c /root/kcptun/server-config.json > kcptun.log 2>&1 &
echo "Kcptun started."
```

2. 停止脚本 vi /root/kcptun/stop.sh
```
#!/bin/bash
echo "Stopping Kcptun..."
PID=`ps -ef | grep server_linux_amd64 | grep -v grep | awk '{print $2}'`
if [ "" !=  "$PID" ]; then
echo "killing $PID"
kill -9 $PID
fi
echo "Kcptun stoped."
```

3. kcptun配置文件 vi /root/kcptun/server-config.json
```
{
"listen": ":443",
"target": "127.0.0.1:10001",
"key": "helloworld",
"crypt": "salsa20",
"mode": "fast2",
"mtu": 1350,
"sndwnd": 1024,
"rcvwnd": 1024,
"datashard": 5,
"parityshard": 5,
"dscp": 46,
"nocomp": true,
"acknodelay": false,
"nodelay": 0,
"interval": 40,
"resend": 0,
"nc": 0,
"sockbuf": 4194304,
"keepalive": 10
}
```

- 启动或停止kcptun
```
sh /root/kcptun/start.sh
sh /root/kcptun/stop.sh
```

---

## 客户端windows环境中的kcptun配置
- kcptun官网 https://github.com/xtaci/kcptun/releases
- client_windows_amd64.exe 放在全部英文目录下
- 创建下面的三个文件：run.vbs, client-config.json, stop.sh
1. 在当前文件夹下，创建 run.vbs
```
Dim RunKcptun
Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")
currentPath = fso.GetFile(Wscript.ScriptFullName).ParentFolder.Path & "\"
configFile = currentPath & "client-config.json"
logFile = currentPath & "kcptun.log"
exeConfig = currentPath & "client_windows_amd64.exe -c " & configFile
cmdLine = "cmd /c " & exeConfig & " > " & logFile & " 2>&1"
WshShell.Run cmdLine, 0, False
'WScript.Sleep 1000
'Wscript.echo cmdLine
Set WshShell = Nothing
Set fso = Nothing
WScript.quit
```
2. 在当前文件夹下，创建client-config.json
```
{
"localaddr": ":12345",
"remoteaddr": "165.227.213.57:443",
"key": "helloworld",
"crypt": "salsa20",
"mode": "fast2",
"conn": 1,
"autoexpire": 60,
"mtu": 1350,
"sndwnd": 128,
"rcvwnd": 1024,
"datashard": 5,
"parityshard": 5,
"dscp": 46,
"nocomp": true,
"acknodelay": false,
"nodelay": 0,
"interval": 40,
"resend": 0,
"nc": 0,
"sockbuf": 4194304,
"keepalive": 10
}
```
3. 在当前文件夹下，创建stop.sh
```
taskkill /f /im client_windows_amd64.exe
```

## 客户端windows环境中的ss配置
- 使用本地的配置
```
127.0.0.1
12345
helloworld(服务端ss的密码，不是kcptun的密码)
chacha20
```
