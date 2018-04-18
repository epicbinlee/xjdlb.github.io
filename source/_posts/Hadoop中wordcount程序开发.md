
---
title: hadoop中wordcount程序开发
date: 2018-04-18 13:09:22
tags: [列表,maven,hadoop]
categories: 开发
toc: true
mathjax: true
---

本文介绍如何利用java和hadoop组件开发wordcount程序。
<!-- more -->
## 开发环境
- windows
- eclipse
- maven
1. Apache Hadoop Common 3.1
2. Apache Hadoop Client Aggregator 3.1
3. Hadoop Core 1.2
4. Apache Hadoop HDFS 3.1
5. Apache Hadoop MapReduce Core 3.1

## 添加依赖后maven报错
- 报错
```
Buiding Hadoop with Eclipse / Maven - Missing artifact jdk.tools:jdk.tools:jar:1.6
```

- 解决
```
# cmd
C:\Users\BinLee>java -version
java version "1.8.0_144"
Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
# 添加下面的依赖到maven的pom.xml
<dependency>
    <groupId>jdk.tools</groupId>
    <artifactId>jdk.tools</artifactId>
    <version>1.8.0_144</version>
    <scope>system</scope>
    <systemPath>${JAVA_HOME}/lib/tools.jar</systemPath>
</dependency>
```
