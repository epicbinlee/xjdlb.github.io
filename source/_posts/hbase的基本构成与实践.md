
---
title: hbase的基本构成与实践
date: 2018-04-24 21:14:15
tags: [列表,configuration,原理,hbase]
categories: 配置
toc: true
mathjax: true
---

本文介绍hbase的基本构成与实践。

<!-- more -->

## hbase的基本构成

- 表空间 namespace
```
两个默认的表空间
hbase： 系统默认表空间
default： 不指定自动加入的表空间
root@ubuntu:~/app/hadoop/bin# ./hadoop fs -ls /hbase/data
Found 2 items
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/default
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/hbase
```

- 表 table
```
表的存在形式：表以文件夹的形式存在于hdfs中
表的基本组成是：RowKey, Column Family, Column, Value(Cell):Byte array
表的物理属性：以RowKey进行字典排序，行的方向存在多个Region，Region是存储和负载均衡的最小单元，不同的Region分布到不同的RegionServer上
#=============================
root@ubuntu:~/app/hadoop/bin# ./hadoop fs -ls /hbase/data/hbase
Found 2 items
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/hbase/meta
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/hbase/namespace
#-----------------------------
root@ubuntu:~/app/hadoop/bin# ./hadoop fs -ls /hbase/data/hbase/meta
Found 3 items
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/hbase/meta/.tabledesc
drwxr-xr-x   - root supergroup          0 2018-04-23 20:18 /hbase/data/hbase/meta/.tmp
drwxr-xr-x   - root supergroup          0 2018-04-24 01:45 /hbase/data/hbase/meta/1588230740
#-----------------------------
root@ubuntu:~/app/hadoop/bin# ./hadoop fs -ls /hbase/data/hbase/meta/1588230740
Found 4 items
-rw-r--r--   1 root supergroup         32 2018-04-23 20:18 /hbase/data/hbase/meta/1588230740/.regioninfo
drwxr-xr-x   - root supergroup          0 2018-04-24 01:45 /hbase/data/hbase/meta/1588230740/.tmp
drwxr-xr-x   - root supergroup          0 2018-04-24 01:45 /hbase/data/hbase/meta/1588230740/info
drwxr-xr-x   - root supergroup          0 2018-04-24 01:37 /hbase/data/hbase/meta/1588230740/recovered.edits
#-----------------------------
root@ubuntu:~/app/hbase/bin# ./hbase shell
2018-04-24 06:29:19,776 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.2.6, rUnknown, Mon May 29 02:25:32 CDT 2017
hbase(main):001:0>
#-----------------------------
hbase(main):001:0> create 'maizi_hbase','f'
0 row(s) in 2.5670 seconds
=> Hbase::Table - maizi_hbase
hbase(main):002:0>
#=============================
访问 http://192.168.231.150:50070/explorer.html#/hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458
得到hbse的路径
#-----------------------------
root@ubuntu:~/app/hadoop/bin# ./hadoop fs -ls /hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458
Found 3 items
-rw-r--r--   1 root supergroup         46 2018-04-24 06:30 /hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458/.regioninfo
drwxr-xr-x   - root supergroup          0 2018-04-24 06:30 /hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458/f
drwxr-xr-x   - root supergroup          0 2018-04-24 06:30 /hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458/recovered.edits
#-----------------------------
上述操作中，6a028f21704f8fc6bf298598f6b8a458为Region的编号
#=============================
访问 http://192.168.231.150:16010/table.jsp?name=maizi_hbase 得到hbase的管理界面，可以看出路径结构
```

- 列族 column family
```
很多列的集合
hbase中的每个列都属于一个column family
每个column family存在于hdfs的单独文件中
列名以column family为前缀， info:name, info:age
#-----------------------------
/hbase/data/default/maizi_hbase/6a028f21704f8fc6bf298598f6b8a458/f
数据库/数据/表空间/表/region/列族
#-----------------------------
创建表的时候必须定义列族，因为在hdfs上必须要创建文件夹
#-----------------------------
何如设计RowKey是经典问题？
```

- 列
```
存放数据的地方
```

- RowKey
```
可以理解为主键，最大长度为64k，RowKey保存为字节数组
是非关系型数据库中key-value类型的数据的key
自动字典排序
散列原则，分布到不同的Region中，RegionServer的负载均衡问题
```
