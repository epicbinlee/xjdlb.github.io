
---
title: PE mr configuration and yarn resource manager ha
date: 2018-04-30 14:26:24
tags: [列表,mapreduce,yarn,hadoop]
categories: configuration
toc: true
mathjax: true
---

本文介绍如何将MR计算模型集成到hdfs ha中，并且实现yarn的RS的高可用。

<!-- more -->

## 集群配置需求

- 集群配置地点
```
    NN  DN  JN  ZK  ZKFC    RS
n1  1           1   1
n2  1   1   1   1   1
n3      1   1   1           1
n4      1   1               1
```

## MR配置，yarn RS ha配置

- mapred-site.xml
```
vim mapred-site.xml 
<configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
</configuration>
```

- yarn-site.xml
```
<configuration>
        <!-- 配置MR -->
        <property>
          <name>yarn.nodemanager.aux-services</name>
          <value>mapreduce_shuffle</value>
        </property>
        <!-- resourcemanager高可用ha -->
        <property>
          <name>yarn.resourcemanager.ha.enabled</name>
          <value>true</value>
        </property>
        <property>
          <name>yarn.resourcemanager.cluster-id</name>
          <value>sxt2yarn</value>
        </property>
        <property>
          <name>yarn.resourcemanager.ha.rm-ids</name>
          <value>rm1,rm2</value>
        </property>
        <property>
          <name>yarn.resourcemanager.hostname.rm1</name>
          <value>n3</value>
        </property>
        <property>
          <name>yarn.resourcemanager.hostname.rm2</name>
          <value>n4</value>
        </property>
        <property>
          <name>yarn.resourcemanager.webapp.address.rm1</name>
          <value>n3:8088</value>
        </property>
        <property>
          <name>yarn.resourcemanager.webapp.address.rm2</name>
          <value>n4:8088</value>
        </property>
        <!-- 配置zk集群 -->
        <property>
          <name>yarn.resourcemanager.zk-address</name>
          <value>n1:2181,n2:2181,n3:2181</value>
        </property>
</configuration>
```

- 同步到其他机器上
```
scp ./*.xml n2:`pwd`
scp ./*.xml n3:`pwd`
scp ./*.xml n4:`pwd`
```

## MR启动，查看yarn RS ha

- 停掉所有
```
zkServer.sh stop
stop-dfs.sh
kill -9 pid
```

- 启动zk
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

- 启动所有
```
root@n1:~# start-all.sh 
This script is Deprecated. Instead use start-dfs.sh and start-yarn.sh
Starting namenodes on [n1 n2]
n1: starting namenode, logging to /root/app/hadoop/logs/hadoop-root-namenode-n1.out
n2: starting namenode, logging to /root/app/hadoop/logs/hadoop-root-namenode-n2.out
n4: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n4.out
n2: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n2.out
n3: starting datanode, logging to /root/app/hadoop/logs/hadoop-root-datanode-n3.out
Starting journal nodes [n2 n3 n4]
n2: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n2.out
n3: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n3.out
n4: starting journalnode, logging to /root/app/hadoop/logs/hadoop-root-journalnode-n4.out
Starting ZK Failover Controllers on NN hosts [n1 n2]
n1: starting zkfc, logging to /root/app/hadoop/logs/hadoop-root-zkfc-n1.out
n2: starting zkfc, logging to /root/app/hadoop/logs/hadoop-root-zkfc-n2.out
starting yarn daemons
starting resourcemanager, logging to /root/app/hadoop/logs/yarn-root-resourcemanager-n1.out
n3: starting nodemanager, logging to /root/app/hadoop/logs/yarn-root-nodemanager-n3.out
n2: starting nodemanager, logging to /root/app/hadoop/logs/yarn-root-nodemanager-n2.out
n4: starting nodemanager, logging to /root/app/hadoop/logs/yarn-root-nodemanager-n4.out
```

- 查看进程
```
root@n1:~# jps
6162 Jps
5363 QuorumPeerMain
5923 DFSZKFailoverController
5578 NameNode
#
root@n2:~# jps
5600 NodeManager
5715 Jps
5044 NameNode
5157 DataNode
5448 DFSZKFailoverController
4920 QuorumPeerMain
5294 JournalNode
#
root@n3:~# jps
3856 Jps
3746 NodeManager
3477 DataNode
3609 JournalNode
3354 QuorumPeerMain
#
root@n4:~# jps
3441 DataNode
3575 JournalNode
3817 Jps
3710 NodeManager
```

- 查看DN(也是nodemanager的配置，RS yarn需要手动启动)
```
root@n1:~#  cat /root/app/hadoop/etc/hadoop/slaves
n2
n3
n4
```

- 启动resourcemanager/yarn/nodemanager（n3, n4）
```
yarn-daemon.sh start resourcemanager
```

- 启动结果slaves配置就是DN和nodemanager的配置
```
root@n3:~# yarn-daemon.sh start resourcemanager
starting resourcemanager, logging to /root/app/hadoop/logs/yarn-root-resourcemanager-n3.out
root@n3:~# jps
3905 ResourceManager
3746 NodeManager
3477 DataNode
3609 JournalNode
3354 QuorumPeerMain
3951 Jps
root@n3:~# 
#
root@n4:~# yarn-daemon.sh start resourcemanager
starting resourcemanager, logging to /root/app/hadoop/logs/yarn-root-resourcemanager-n4.out
root@n4:~# jps
3441 DataNode
3859 ResourceManager
3910 Jps
3575 JournalNode
3710 NodeManager
root@n4:~# 
#
root@n2:~# jps
5600 NodeManager
5764 Jps
5044 NameNode
5157 DataNode
5448 DFSZKFailoverController
4920 QuorumPeerMain
5294 JournalNode
root@n2:~# 
#
root@n1:~# jps
5363 QuorumPeerMain
5923 DFSZKFailoverController
5578 NameNode
6333 Jps
```

- 查看yarn http端口8088
```
root@n3:~# netstat -nltp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:33139         0.0.0.0:*               LISTEN      3477/java       
tcp        0      0 127.0.1.1:53            0.0.0.0:*               LISTEN      1210/dnsmasq    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1181/sshd       
tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      1048/cupsd      
tcp        0      0 0.0.0.0:50010           0.0.0.0:*               LISTEN      3477/java       
tcp        0      0 0.0.0.0:50075           0.0.0.0:*               LISTEN      3477/java       
tcp        0      0 0.0.0.0:8480            0.0.0.0:*               LISTEN      3609/java       
tcp        0      0 0.0.0.0:50020           0.0.0.0:*               LISTEN      3477/java       
tcp        0      0 0.0.0.0:8485            0.0.0.0:*               LISTEN      3609/java       
tcp6       0      0 192.168.44.102:3888     :::*                    LISTEN      3354/java       
tcp6       0      0 :::22                   :::*                    LISTEN      1181/sshd       
tcp6       0      0 ::1:631                 :::*                    LISTEN      1048/cupsd      
tcp6       0      0 192.168.44.102:8088     :::*                    LISTEN      3905/java       
tcp6       0      0 :::41529                :::*                    LISTEN      3354/java       
tcp6       0      0 :::13562                :::*                    LISTEN      3746/java       
tcp6       0      0 192.168.44.102:8030     :::*                    LISTEN      3905/java       
tcp6       0      0 192.168.44.102:8031     :::*                    LISTEN      3905/java       
tcp6       0      0 192.168.44.102:8032     :::*                    LISTEN      3905/java       
tcp6       0      0 192.168.44.102:8033     :::*                    LISTEN      3905/java       
tcp6       0      0 :::2181                 :::*                    LISTEN      3354/java       
tcp6       0      0 :::8040                 :::*                    LISTEN      3746/java       
tcp6       0      0 :::8042                 :::*                    LISTEN      3746/java       
tcp6       0      0 :::43405                :::*                    LISTEN      3746/java 
```

- 查看wenUI
```
http://n1:50070/dfshealth.html#tab-overview
http://n2:50070/dfshealth.html#tab-overview
观察下n1和n2谁是active和standby
观察下datanode是不是全n1,n2,n3
观察下文件系统是不是active的NN可用，standby的NN不可用
http://n3:8088/cluster
http://n4:8088/cluster(会自动跳转到上面的链接，n4 RS 处于standby状态)
n3和n4上启动RS，自动关联到nodemanager，管理DN，查看节点ActiveNodes是不是和DN数目一样3个
```

## 测试yarn RS ha
- 测试ha的状态
```
yarn-daemon.sh stop resourcemanager（n3）
jps
挂掉n3 RS，看看n4:8088的状态active
再次启动n3，这时候n3处于standby状态
```

## 生产环境的高可用Hadoop集群的搭建总结
- 高可用解决了1.x的单节点不可靠的问题
- 高可用ha一方面指的是hdfs的namenode的高可用，解决NN的单节点故障问题
- 高可用ha另一方面指的是yarn的resource manager的高可用，解决yarn单节点不可靠的问题
- 2.x为什么引入了yarn呢？yarn可用保障计算的高可靠
- 实验的一般流程：
1. Hadoop单机模式：直接跑jar文件
2. 伪分布式模式：配置成分布式模式，只有一台vm
3. 全分布式模式：使用1.x架构，具有secondary NN
4. 全分布式hdfs NN ha模式：使用了QJM实现了hdfs的高可用架构
5. 全分布式hdfs NN ha + yarn RS ha模式：使用了集群实现了yarn对DN的管理
- 对比可以发现1.x和2.x的共同点都是移动计算不移动数据
- 对比可以发现1.x和2.x的差异性在于1.x由client直接操作DN，但是2.x加入了yarn层管理DN
- 2.x有两个瓶颈NN和RS，因此需要ha处理
- 其中4中的QJM，包含了集群：
1. 设计目标NN ha
2. 从下到上：DN-->NN active/NN standby-->JN(edits管理)-->zk中zkfc-->zk
- 其中5包含了集群：
1. 设计目标是yarn中的resource manager
2. yarn的管理包含了：resource manager（RS）-->node manager
3. DN-->NN active/NN standby-->JN(edits管理)-->zk中zkfc-->zk-->RS