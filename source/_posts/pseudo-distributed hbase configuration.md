
---
title: pseudo-distributed hbase configuration
date: 2018-04-24 11:56:31
tags: [列表,hadoop,configuration,hbase]
categories: configuration
toc: true
mathjax: true
---

This article describes how to build a pseudo-distributed hbase on a virtual machine.

<!-- more -->

## preconditions
- jdk environment
```
root@ubuntu:~# echo $JAVA_HOME
/root/app/jdk1.8.0_171
```
- a pseudo-distributed hadoop
```
root@ubuntu:~/app/hadoop/sbin# jps
12550 NodeManager
34152 Jps
12408 ResourceManager
12024 DataNode
12235 SecondaryNameNode
11852 NameNode
```

- test
```
http://localhost:50070
http://192.168.231.150:8099
http://192.168.231.150:8042
```

## configure hbase

- download hbase from [apache mirrors](http://mirror.bit.edu.cn/apache/)
- extract files from hbase-2.0.0-beta-2-bin.tar.gz
- configure xml files
```
hbase-env.sh
hbase-site.xml
regionservers
#================================
root@ubuntu:~/app/hbase/conf# pwd
/root/app/hbase/conf
#================================
root@ubuntu:~/app/hbase/conf# ll
total 48
drwxr-xr-x 2 root root 4096 Apr 23 20:15 ./
drwxr-xr-x 8 root root 4096 Apr 23 20:17 ../
-rw-r--r-- 1 root root 1811 Dec 26  2015 hadoop-metrics2-hbase.properties
-rw-r--r-- 1 root root 4537 Jan 28  2016 hbase-env.cmd
-rw-r--r-- 1 root root 7537 Apr 23 20:12 hbase-env.sh
-rw-r--r-- 1 root root 2257 Dec 26  2015 hbase-policy.xml
-rw-r--r-- 1 root root 1355 Apr 23 20:09 hbase-site.xml
-rw-r--r-- 1 root root 4603 May 28  2017 log4j.properties
-rw-r--r-- 1 root root   16 Apr 23 20:15 regionservers
#================================
vim hbase-env.sh
# The java implementation to use.  Java 1.7+ required.
# export JAVA_HOME=/usr/java/jdk1.6.0/
export JAVA_HOME=/root/app/jdk1.8.0_171
#--------------------------------
# Tell HBase whether it should manage it's own instance of Zookeeper or not.
# export HBASE_MANAGES_ZK=true
export HBASE_MANAGES_ZK=true
#================================
vim regionservers
root@ubuntu:~/app/hbase/conf# cat regionservers
192.168.231.150
#================================
vim hbase-site.xml
<configuration>
    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://192.168.231.150:9000/hbase</value>
    </property>
	<property>
        <name>ha.zookeeper.quorum</name>
	<value>192.168.231.150</value>
    </property>
	<property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
</configuration>
```

## run/stop hbase
- run hbase
```
root@ubuntu:~/app/hbase/bin# ./start-hbase.sh
localhost: starting zookeeper, logging to /root/app/hbase/bin/../logs/hbase-root-zookeeper-ubuntu.out
starting master, logging to /root/app/hbase/bin/../logs/hbase-root-master-ubuntu.out
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
192.168.231.150: starting regionserver, logging to /root/app/hbase/bin/../logs/hbase-root-regionserver-ubuntu.out
192.168.231.150: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
192.168.231.150: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
root@ubuntu:~/app/hbase/bin# jps
34545 HQuorumPeer
34757 HRegionServer
12550 NodeManager
12408 ResourceManager
12024 DataNode
34618 HMaster
12235 SecondaryNameNode
11852 NameNode
35053 Jps
```
- test hbase
```
http://192.168.231.150:16010
```
