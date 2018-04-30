
---
title: PE hadoop 2.x hdfs availablity implement
date: 2018-04-30 14:08:31
tags: [列表,ha,hadoop,hdfs]
categories: configuration
toc: true
mathjax: true
---

本文介绍如何在hdfs上实现namenode集群的高可用。

<!-- more -->

## 集群配置需求

- 集群配置地点
```
    NN  DN  JN  ZK  ZKFC
n1  1           1   1
n2  1   1   1   1   1
n3      1   1   1   
n4      1   1
```

## 配置HDFS

- hdfs-site.xml
```
vim /root/app/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
        <!-- 配置NN空间 -->
        <property>
                <name>dfs.nameservices</name>
                <value>sxt</value>
        </property>
        <property>
                <name>dfs.ha.namenodes.sxt</name>
                <value>nn1,nn2</value>
        </property>
        <property>
                <name>dfs.namenode.rpc-address.sxt.nn1</name>
                <value>n1:8020</value>
        </property>
        <property>
                <name>dfs.namenode.rpc-address.sxt.nn2</name>
                <value>n2:8020</value>
        </property>
        <property>
                <name>dfs.namenode.http-address.sxt.nn1</name>
                <value>n1:50070</value>
        </property>
        <property>
                <name>dfs.namenode.http-address.sxt.nn2</name>
                <value>n2:50070</value>
        </property>
        <!-- 配置JN能处理的Node，可以理解为DN -->
        <property>
                <name>dfs.namenode.shared.edits.dir</name>
                <value>qjournal://n2:8485;n3:8485;n4:8485/sxt</value>
        </property>
        <property>
                <name>dfs.client.failover.proxy.provider.sxt</name>
                <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
        </property>
        <!-- 配置密钥 -->
        <property>
                <name>dfs.ha.fencing.methods</name>
                <value>sshfence</value>
        </property>
        <property>
                <name>dfs.ha.fencing.ssh.private-key-files</name>
                <value>/root/.ssh/id_rsa</value>
        </property>
        <!-- 配置JN的临时文件夹 -->
        <property>
                <name>dfs.journalnode.edits.dir</name>
                <value>/opt/journal/node/data</value>
        </property>
        <!-- 单节点故障自动迁移 -->
        <property>
                <name>dfs.ha.automatic-failover.enabled</name>
                <value>true</value>
        </property>
</configuration>
```

- core-site.xml
```
vim /root/app/hadoop/etc/hadoop/core-site.xml
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://sxt</value>
        </property>
        <property>
                <name>hadoop.tmp.dir</name>
                <value>/opt/hadoop</value>
        </property>
        <!-- 配置Quorum Journal Manager的zk集群，JN管理集群 -->
        <property>
                <name>ha.zookeeper.quorum</name>
                <value>n1:2181,n2:2181,n3:2181</value>
        </property>
</configuration>
```

## 配置zookeeper

- 环境变量
```
cat /etc/profile
export ANT_HOME=/root/app/ant
export HADOOP_HOME=/root/app/hadoop
export JAVA_HOME=/root/app/jdk
export JRE_HOME=/root/app/jdk/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$ANT_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export ZOOKEEPER_HOME=/root/app/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin
注意只有前面三台的zk路径加入环境变量
```

- 配置文件
```
cat /root/app/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
# dataDir=/tmp/zookeeper
dataDir=/opt/zookeeper
server.1=n1:2888:3888
server.2=n2:2888:3888
server.3=n3:2888:3888
```

- 分别配置/opt/zookeeper目录，创建myid文件，加入1, 2, 3

- 同时启动zk
```
zkServer.sh start
```

- 查看状态
```
zkServer.sh status
```

- 启动输出
```
root@n1:~# zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
root@n1:~# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Mode: follower
```

- n1拷贝zookeeper到n2, n3, n4
```
scp -r ./dir n1:`pwd`
```

## 启动ZK

- 启动并查看状态（1, 2, 3同时启动）
```
zkServer.sh start
zkServer.sh status
```

## 启动JN

- 在n2. n3, n4启动JN
```
hadoop-daemon.sh start journalnode
```

- 输出
```
root@n2:~# hadoop-daemon.sh start journalnode
starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n2.out
root@n2:~# jps
1751 QuorumPeerMain
1895 JournalNode
1945 Jps
```

## 启动NN，高可用HA操作

- 在一台NN格式化（NN:n1）
```
hdfs namenode -format
```

- 在没有格式化的另外一台hadoop执行standby操作（NN:n2）
```
hdfs namenode -bootstrapStandby
```

- 报错提示n1没有启动namenode，先启动namenode
```
hadoop-daemon.sh start namenode
```

- 在此执行standby成功（格式化+启动n1，standby另外n2）
```
18/04/29 11:14:41 INFO namenode.NameNode: registered UNIX signal handlers for [TERM, HUP, INT]
18/04/29 11:14:41 INFO namenode.NameNode: createNameNode [-bootstrapStandby]
#=====================================================
About to bootstrap Standby ID nn2 from:
           Nameservice ID: sxt
        Other Namenode ID: nn1
  Other NN's HTTP address: http://n1:50070
  Other NN's IPC  address: n1/192.168.44.100:8020
             Namespace ID: 1765158274
            Block pool ID: BP-1441163464-192.168.44.100-1525025632122
               Cluster ID: CID-2e601647-294c-4e70-8e72-7a82bea94fa9
           Layout version: -63
       isUpgradeFinalized: true
#=====================================================
18/04/29 11:14:42 INFO common.Storage: Storage directory /opt/hadoop/dfs/name has been successfully formatted.
18/04/29 11:14:43 INFO namenode.TransferFsImage: Opening connection to http://n1:50070/imagetransfer?getimage=1&txid=0&storageInfo=-63:1765158274:0:CID-2e601647-294c-4e70-8e72-7a82bea94fa9
18/04/29 11:14:43 INFO namenode.TransferFsImage: Image Transfer timeout configured to 60000 milliseconds
18/04/29 11:14:43 INFO namenode.TransferFsImage: Transfer took 0.00s at 0.00 KB/s
18/04/29 11:14:43 INFO namenode.TransferFsImage: Downloaded file fsimage.ckpt_0000000000000000000 size 321 bytes.
18/04/29 11:14:43 INFO util.ExitUtil: Exiting with status 0
18/04/29 11:14:43 INFO namenode.NameNode: SHUTDOWN_MSG: 
SHUTDOWN_MSG: Shutting down NameNode at n2/192.168.44.101
```

## 查看HA效果

- 在一个NN上格式化zookeeper（n1）
```
hdfs zkfc -formatZK
```

- 在单节点NN启动n1
```
start-dfs.sh
```

- 输出
```
Starting namenodes on [n1 n2]
n1: namenode running as process 2411. Stop it first.
n2: namenode running as process 2239. Stop it first.
n2: datanode running as process 2413. Stop it first.
n4: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n4.out
n3: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n3.out
Starting journal nodes [n2 n3 n4]
n3: journalnode running as process 2207. Stop it first.
n2: journalnode running as process 1895. Stop it first.
n4: journalnode running as process 1732. Stop it first.
Starting ZK Failover Controllers on NN hosts [n1 n2]
n2: zkfc running as process 2804. Stop it first.
n1: starting zkfc, logging to /root/app/hadoop/logs/hadoop-root-zkfc-n1.out
root@n1:~# 
```

- 进程查看
```
root@n1:~# jps
3091 DFSZKFailoverController
3285 Jps
2411 NameNode
2188 QuorumPeerMain
#
root@n2:~# jps
3184 Jps
2804 DFSZKFailoverController
1751 QuorumPeerMain
1895 JournalNode
2413 DataNode
2239 NameNode
#
root@n3:~# jps
2512 Jps
2121 QuorumPeerMain
2362 DataNode
2207 JournalNode
#
root@n4:~# jps
1732 JournalNode
2039 Jps
1887 DataNode
#
    NN  DN  JN  ZK  ZKFC
n1  1           1   1
n2  1   1   1   1   1
n3      1   1   1   
n4      1   1
```

- 查看webUI
```
http://n2:50070/dfshealth.html#tab-overview
Overview 'n2:8020' (active)
#
http://n1:50070/dfshealth.html#tab-overview
Overview 'n1:8020' (standby)
#
Datanode Information
三个
#
http://n1:50070/explorer.html#/
Operation category READ is not supported in state standby
#
http://n2:50070/explorer.html#/
Browse Directory 可见
```

- 故障测试
```
hadoop-daemon.sh stop namenode（n2）
查看网页，文件系统，DN
hadoop-daemon.sh start namenode（n2）
再次查看交换了状态
Overview 'n1:8020' (active)
Overview 'n2:8020' (standby)
```

## 重新启动与停止
- 启停操作
```
stop-dfs.sh
root@n1:~# stop-dfs.sh 
Stopping namenodes on [n1 n2]
n1: stopping namenode
n2: stopping namenode
n3: stopping datanode
n4: stopping datanode
n2: stopping datanode
Stopping journal nodes [n2 n3 n4]
n2: stopping journalnode
n3: stopping journalnode
n4: stopping journalnode
Stopping ZK Failover Controllers on NN hosts [n1 n2]
n1: stopping zkfc
n2: stopping zkfc
#
下次启动jps查看ZK是不是启动
先启动ZK，在启动DFS
#
root@n1:~# zkServer.sh start（根据列表中的三台都同时启动zk）
root@n1:~# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Mode: follower
#
root@n1:~# start-dfs.sh 
Starting namenodes on [n1 n2]
n1: starting namenode, logging to /root/app/hadoop/logs/hadoop-root-namenode-n1.out
n2: starting namenode, logging to /root/app/hadoop/logs/hadoop-root-namenode-n2.out
n4: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n4.out
n3: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n3.out
n2: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n2.out
Starting journal nodes [n2 n3 n4]
n2: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n2.out
n3: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n3.out
n4: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n4.out
Starting ZK Failover Controllers on NN hosts [n1 n2]
n1: starting zkfc, logging to /root/app/hadoop/logs/hadoop-root-zkfc-n1.out
n2: starting zkfc, logging to /root/app/hadoop/logs/hadoop-root-zkfc-n2.out
```