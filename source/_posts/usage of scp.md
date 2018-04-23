
---
title: usage of scp
date: 2018-04-23 19:48:40
tags: [列表,cmd,linux]
categories: linux
toc: true
mathjax: true
---

this article describes how download/upload files from server using scp command line.

<!-- more -->


## usage of scp

1. download file from server
```
scp root@servername:/path/filename /tmp/local_destination
scp root@192.168.0.101:/home/kimi/test.txt /home/kimi/test.txt
```

2. upload file to server
```
scp /path/local_filename root@servername:/path  
scp /var/www/test.php root@192.168.0.101:/var/www/
```
  
3. download directory to client
```
scp -r root@servername:remote_dir/ /tmp/local_dir 
scp -r root@192.168.0.101:/home/kimi/test /tmp/local_dir
```

4. upload directory to server
```
scp -r /tmp/local_dir root@servername:remote_dir
scp -P 22 -r test root@192.168.0.101:/var/www/
```