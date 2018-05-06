
---
title: HBase基础开发
date: 2018-05-05 16:45:31
tags: [列表,HBase,Hadoop]
categories: 开发
toc: true
mathjax: true
---

本文介绍了如何利用eclipse进行HBase相关的开发。

<!-- more -->


## 模拟场景

- 运营商通话记录
查询通话详单
本机号码 主叫/被叫 通话时长 时间 对方号码 号码属性 归属地

## 第1次启动分布式hadoop和hbase

- 删除所有的临时文件夹(重要)
- 启动zk集群，三台，最好在xshell下面一起启动，并且查看状态status
- edits交给JN,手动启动三个JN
- 格式化一台NN，并启动这一台(只能格式化一次，不然重新来)
- 另外一台NN执行同步standby
- 格式化zk
- 启动dfs(可以直接全部启动)
- 最后启动RS
```
rm -rdf /opt/hadoop/* /opt/journal/* /opt/zookeeper/v* /opt/zookeeper/z*
zkServer.sh start(xshell同时启动)
vim /root/app/hadoop/etc/hadoop/slaves(配置好datanode)
hadoop-daemon.sh start journalnode(根据hdfs配置文件，n2 n3 n4)
hdfs namenode -format(选一个NN格式化，一次机会，失败重头再来)
hadoop-daemon.sh start namenode(格式化的NN上)
hdfs namenode -bootstrapStandby(n2,没有格式化的NN上)
hdfs zkfc -formatZK(n1)
start-all.sh(n1)
yarn-daemon.sh start resourcemanager(指定的机器，n3 n4)
start-hbase.sh
```

## 第2次及以后启动分布式hadoop和hbase

- 启动过程
```
zkServer.sh start(xshell同时启动)
vim /root/app/hadoop/etc/hadoop/slaves(配置好datanode)
start-all.sh(n1)
yarn-daemon.sh start resourcemanager(指定的机器，n3 n4)
start-hbase.sh
```

## eclipse连接hadoop

- 连接过程具体[参考](https://leebin.top/2018/04/30/%E6%9C%AC%E5%9C%B0eclipse%E9%93%BE%E6%8E%A5%E8%BF%9C%E7%A8%8Bhadoop%E7%BC%96%E5%86%99hdfs%E6%B5%8B%E8%AF%95%E4%BB%A3%E7%A0%81/)

## 新建项目

- 新建项目
- 到入hbase安装包下面的lib文件夹到项目目录下
- 写代码创建表
```
package com.hikvision.hbase;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.log4j.BasicConfigurator;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
public class HBase_test {
	HBaseAdmin hAdmin;
	String TABLE_NAME = "phone";
	// 列族 一般是1到2个
	String COLUMN_FAMILY = "cf1";
	@SuppressWarnings("deprecation")
	@Before
	public void begin() throws Exception {
		BasicConfigurator.configure();
		Configuration conf = new Configuration();
		conf.set("hbase.zookeeper.quorum", "n1,n2,n3");
		conf.set("hbase.zookeeper.property.clientPort", "2181");
		conf.set("hbase.master", "n5:16020");
		hAdmin = new HBaseAdmin(conf);
	}
	@After
	public void end() {
		if (hAdmin != null) {
			try {
				hAdmin.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	@Test
	public void createTable() throws Exception {
		// 0.容错,先判断是不是存在
		if (hAdmin.tableExists(TABLE_NAME)) {
			hAdmin.disableTable(TABLE_NAME);
			hAdmin.deleteTable(TABLE_NAME);
		}
		// 1.表描述
		HTableDescriptor desc = new HTableDescriptor(TableName.valueOf(TABLE_NAME));
		// 2.列族描述
		HColumnDescriptor family = new HColumnDescriptor(COLUMN_FAMILY);
		// 2.1读缓存
		family.setBlockCacheEnabled(true);
		family.setInMemory(true);
		// 2.2设定最大版本数默认为1
		family.setMaxVersions(1);
		// 为表指定列族
		desc.addFamily(family);
		hAdmin.createTable(desc);
	}
}
```

- 查看hbase shell
```
root@n5:~# hbase shell
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/root/app/hbase/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/root/app/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.2.6, rUnknown, Mon May 29 02:25:32 CDT 2017
hbase(main):001:0> list
TABLE                                                                                                                                                                                                            
phone                                                                                                                                                                                                            
t3                                                                                                                                                                                                               
tab-1                                                                                                                                                                                                            
3 row(s) in 0.2560 seconds
=> ["phone", "t3", "tab-1"]
hbase(main):002:0> describe "phone"
Table phone is ENABLED                                                                                                                                                                                           
phone                                                                                                                                                                                                            
COLUMN FAMILIES DESCRIPTION                                                                                                                                                                                      
{NAME => 'cf1', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'true', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSIONS => '0', BLOCKCACH
E => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                                                                                                                                                     
1 row(s) in 0.1350 seconds
```