
---
title: ubuntu中hadoop单机模式搭建
date: 2018-04-18 13:09:22
tags: [列表,hadoop]
categories: 配置
toc: true
mathjax: true
---

本文介绍如何搭建hadoop单机版本/独立模式/standalone模式？
<!-- more -->

## ubuntu中的java环境变量配置
```
sudo vim /etc/profile
export JAVA_HOME=/root/app/jdk1.8.0_171
export JRE_HOME=/root/app/jdk1.8.0_171/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
source /etc/profile
java -version
```

## 
