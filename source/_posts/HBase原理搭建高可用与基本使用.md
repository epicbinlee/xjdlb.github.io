
---
title: HBase原理搭建高可用与基本使用
date: 2018-05-03 21:34:47
tags: [列表,HBase,Hadoop]
categories: configuration
toc: true
mathjax: true
---

本文介绍如何安装并使用HBase。

<!-- more -->

## 伪分布式的HBase环境搭建Pseudo-Distributed Local Install [参考](https://hbase.apache.org/book.html#standalone_dist)

- 配置
```
<property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rootdir</name>
  <value>hdfs://localhost:8020/hbase</value>
</property>
```
## 完全分布式安装

- 架构

VM|NN|DN|JN|ZK|ZKFC|RS|HM|HRS
--|--|--|--|--|--|--|--|--
n1|y|n|n|y|y|n|y(b)|n
n2|y|y|y|y|y|n|n|y
n3|n|y|y|y|n|y|n|y
n4|n|y|y|n|n|y|n|y
n5|n|y|n|n|n|n|y(m)|n
n6|n|y|n|n|n|n|n|n



- hbase-env.sh
```
export JAVA_HOME=/root/app/jdk
export HBASE_MANAGES_ZK=false (不启动自带的zookeeper)
```

- hbase-site.xml
```
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://sxt:8020/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>n1,n2,n3</value>
  </property>
</configuration>
```

- conf/regionservers
```
#根据架构把n5设定为HMaster，下面的为HReginServer
n2
n3
n4
```

- conf/backup-masters file(master的HA)
```
vim backup-masters
n1
#根据架构将n1设定为HMaster从节点
```

- HDFS Client Configuration(hbase访问hdfs)
```
copy hdfs-site.xml ${HBASE_HOME}/conf
root@n1:~/app/hbase/conf# pwd
/root/app/hbase/conf
cp /root/app/hadoop/etc/hadoop/hdfs-site.xml ./
```

- 启动
```
#-----------------------------------
在n5 HMaster主节点启动
root@n5:~/app/hbase/conf# jps
1058 NodeManager
962 DataNode
2706 HMaster
3083 Jps
#-----------------------------------
在n2,n3,n4查看HRegionServer
root@n4:~# jps
1041 DataNode
949 JournalNode
2618 Jps
2396 HRegionServer
1198 NodeManager
1263 ResourceManager
```

- webUI查看
```
主节点 http://n5:16010/master-status
从节点 http://n1:16010/master-status
root@n5:~/app/hbase/conf# netstat -ntlp | grep "java"
tcp        0      0 0.0.0.0:50010           0.0.0.0:*               LISTEN      962/java        
tcp        0      0 0.0.0.0:50075           0.0.0.0:*               LISTEN      962/java        
tcp        0      0 0.0.0.0:50020           0.0.0.0:*               LISTEN      962/java        
tcp        0      0 127.0.0.1:42933         0.0.0.0:*               LISTEN      962/java        
tcp6       0      0 :::13562                :::*                    LISTEN      1058/java       
tcp6       0      0 192.168.44.105:16000    :::*                    LISTEN      2706/java       
tcp6       0      0 :::8040                 :::*                    LISTEN      1058/java       
tcp6       0      0 :::16010                :::*                    LISTEN      2706/java       
tcp6       0      0 :::8042                 :::*                    LISTEN      1058/java       
tcp6       0      0 :::34187                :::*                    LISTEN      1058/java 
```

## 常见的命令

- 增删改查
```
hbase shell
help
#-----------------------------------
status table_help version whoami
ddl（disable drop enable exist is_disableed is_enabled list show_filters）
namespace（alter_namespace ...）
dml（append put get delete scan）
tools（balancer flush:menorystore2storefile）
replication
snapshots
#-----------------------------------
create
create 'person','cf1','cf2'
#-----------------------------------
lsit
desc 'person'
TTL => 'forever'
#-----------------------------------
put
put 'person','r1','c1','value'
put 'person','0001','cf1:name','xiaoming'
put 'person','0001','cf1:sex','boy'
#-----------------------------------
scan
scan 'person'
#-----------------------------------
get
get 'person','0001','cf1:name'
#-----------------------------------
插入数据
put 'person','0001','cf1:name','xiaoming2'
get 'person','0001','cf1:name'
#-----------------------------------
#查看命名空间
list_namespace
default
hbase
#-----------------------------------
#先禁用再删除
create 'tbl','cf'
list
disable
disabled 'tbl'
list
drop 'tbl'
```

- 查看hbase的文件
单机模式文件在Linux上
伪分布式模式在Linux上
分布式模式在hdfs上
```
D:\HBASE目录结构
└─namespace
    ├─主节点HRegionMaster
    └─域节点HRegionServer
        └─表table
            ├─域HRegion
            │  ├─存储Store
            │  │  ├─内存存储memoryStore
            │  │  ├─内存存储memoryStore1
            │  │  ├─磁盘储存storeFile
            │  │  └─磁盘储存storeFile1
            │  └─存储Store1
            │      ├─内存存储memoryStore
            │      └─内存存储memoryStore1
            └─域HRegion1
                ├─存储Store
                │  ├─内存存储memoryStore
                │  └─内存存储memoryStore1
                └─存储Store1
                    ├─内存存储memoryStore
                    └─内存存储memoryStore1
```

- webUI查看 n1:60010

## HBase 的ha验证

- 创建表
```
#--------------------------------------------
create 'tab-1' ,'cf-1'
put 'tab-1','rk-0001','cf-1:name','xiaoli'
#--------------------------------------------
hbase(main):007:0> scan 'tab-1'
ROW                        COLUMN+CELL                                                                 
 rk-0001                   column=cf-1:name, timestamp=1525506703143, value=xiaoli                     
1 row(s) in 0.2510 seconds
#--------------------------------------------
hbase(main):008:0> get 'tab-1','rk-0001','cf-1:name'
COLUMN                     CELL                                                                        
 cf-1:name                 timestamp=1525506703143, value=xiaoli                                       
1 row(s) in 0.0480 seconds
#--------------------------------------------
put 'tab-1','rk-0001','cf-1:age','18'
#--------------------------------------------
hbase(main):010:0> scan 'tab-1'
ROW                        COLUMN+CELL                                                                 
 rk-0001                   column=cf-1:age, timestamp=1525507159178, value=18                          
 rk-0001                   column=cf-1:name, timestamp=1525506703143, value=xiaoli                     
1 row(s) in 0.0320 seconds
#--------------------------------------------
get 'tab-1','rk-0001','cf-1'
#--------------------------------------------
hbase(main):011:0> get 'tab-1','rk-0001','cf-1'
COLUMN                     CELL                                                                        
 cf-1:age                  timestamp=1525507159178, value=18                                           
 cf-1:name                 timestamp=1525506703143, value=xiaoli                                       
2 row(s) in 0.0200 seconds
```

- 验证
```
#--------------------------------------------
root@n5:~# jps
1058 NodeManager
962 DataNode
5444 Jps
3625 HMaster
#--------------------------------------------
kill -9 3625
查看n5:16010
查看n1:16010
查看hbase shell
scan 'tab-1'
#--------------------------------------------
重新启动n5上的master
#--------------------------------------------
```





