
---
title: ubuntu中hadoop单机模式和伪分布式搭建
date: 2018-04-18 13:09:22
tags: [列表,hadoop]
categories: 配置
toc: true
mathjax: true
---

本文介绍如何搭建hadoop单机版本/独立模式/standalone模式？
<!-- more -->

## ubuntu开启root用户登录的方法
- 设置密码、添加信息
```
sudo passwd -u root
sudo passwd root
su root
cd /usr/share/lightdm/lightdm.conf.d/
vim 50-unity-greeter.conf
# 添加
user-session=ubuntu
greeter-show-manual-login=true
all-guest=false
# 重启
reboot
# 使用user和passwd进入root报错
vim /root/.profile
# 找到mesg n || true
# 改为tty -s && mesg n || true
```

## ubuntu中的java环境变量配置
- 编辑 sudo vim /etc/profile
```
export JAVA_HOME=/root/app/jdk1.8.0_171
export JRE_HOME=/root/app/jdk1.8.0_171/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
source /etc/profile
```
- 验证
```
java -version
```

## 单机版hadoop配置
- [官方文档](http://hadoop.apache.org/docs/r3.1.0/hadoop-project-dist/hadoop-common/SingleCluster.html#Standalone_Operation)

- 生成ssh密钥
```
cd ~
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh localhost
```

- 配置java环境
```
root@ubuntu:~# vim /etc/profile
export JAVA_HOME=/root/app/jdk1.8.0_171
export JRE_HOME=/root/app/jdk1.8.0_171/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
```

- 配置hadoop环境 vim /etc/profile
```
#HADOOP VARIABLES START
export JAVA_HOME=/root/app/jdk1.8.0_171
export HADOOP_HOME=/root/app/hadoop-3.1.0
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
#HADOOP VARIABLES END
source /etc/profile
```

- 单机版测试
```
root@ubuntu:~# /root/app/hadoop-3.1.0/bin/hadoop jar /root/app/hadoop-3.1.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.0.jar
An example program must be given as the first argument.
Valid program names are:
  aggregatewordcount: An Aggregate based map/reduce program that counts the words in the input files.
  aggregatewordhist: An Aggregate based map/reduce program that computes the histogram of the words in the input files.
  bbp: A map/reduce program that uses Bailey-Borwein-Plouffe to compute exact digits of Pi.
  dbcount: An example job that count the pageview counts from a database.
  distbbp: A map/reduce program that uses a BBP-type formula to compute exact bits of Pi.
  grep: A map/reduce program that counts the matches of a regex in the input.
  join: A job that effects a join over sorted, equally partitioned datasets
  multifilewc: A job that counts words from several files.
  pentomino: A map/reduce tile laying program to find solutions to pentomino problems.
  pi: A map/reduce program that estimates Pi using a quasi-Monte Carlo method.
  randomtextwriter: A map/reduce program that writes 10GB of random textual data per node.
  randomwriter: A map/reduce program that writes 10GB of random data per node.
  secondarysort: An example defining a secondary sort to the reduce.
  sort: A map/reduce program that sorts the data written by the random writer.
  sudoku: A sudoku solver.
  teragen: Generate data for the terasort
  terasort: Run the terasort
  teravalidate: Checking results of terasort
  wordcount: A map/reduce program that counts the words in the input files.
  wordmean: A map/reduce program that counts the average length of the words in the input files.
  wordmedian: A map/reduce program that counts the median length of the words in the input files.
  wordstandarddeviation: A map/reduce program that counts the standard deviation of the length of the words in the input files.
```

- 实例测试
```
/root/app/hadoop-3.1.0/bin/hadoop jar /root/app/hadoop-3.1.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.0.jar grep ./input ./output 'dfs[a-z.]+'
cat ./output/*  # 查看结果
rm -r ./output  # 删除结果
# 结果
root@ubuntu:~/app/hadoop-3.1.0# cat ./output/*  
1	dfsadmin
```

## 伪分布式hadoop配置

- 格式化hdfs
```
cd /root/app/hadoop-3.1.0
./bin/hdfs namenode -format
```

- 添加变量到 vim /etc/profile
```
export JAVA_HOME=/root/app/jdk1.8.0_171
export JRE_HOME=/root/app/jdk1.8.0_171/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
#
# HADOOP VARIABLES START
export JAVA_HOME=/root/app/jdk1.8.0_171
export HADOOP_HOME=/root/app/hadoop-3.1.0
#
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
#
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
#
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
#
export HDFS_DATANODE_USER=root
export HDFS_NAMENODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
#
export YARN_RESOURCEMANAGER_USER=root
export HADOOP_SECURE_DN_USER=yarn
export YARN_NODEMANAGER_USER=root
# HADOOP VARIABLES END
```

- 编辑/root/app/hadoop-3.1.0/etc/hadoop/core-site.xml
```
<configuration>
       <property>
            <name>hadoop.tmp.dir</name>
            <value>file:/root/app/hadoop-3.1.0/tmp</value>
       </property>
       <property>
            <name>fs.defaultFS</name>
            <value>hdfs://localhost:9000</value>
       </property>
</configuration>
```

- 编辑/root/app/hadoop-3.1.0/etc/hadoop/hdfs-site.xml
```
<configuration>
        <property>
             <name>dfs.replication</name>
             <value>2</value>
        </property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>file:/root/app/hadoop-3.1.0/tmp/dfs/name</value>
        </property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>file:/root/app/hadoop-3.1.0/tmp/dfs/data</value>
        </property>
		<property>
			<name>dfs.http.address</name>
			<value>0.0.0.0:50070</value>
		</property>
</configuration>
```

- 编辑 hadoop-env.sh
```
vim /root/app/hadoop-3.1.0/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/root/app/jdk1.8.0_171
```

- 编辑 yarn-env.sh
```
vim /root/app/hadoop-3.1.0/etc/hadoop/yarn-env.sh
export JAVA_HOME=/root/app/jdk1.8.0_171
```

- 编辑 mapred-env.sh
```
vim /root/app/hadoop-3.1.0/etc/hadoop/mapred-env.sh
export JAVA_HOME=/root/app/jdk1.8.0_171
```

## hadoop的使用
- 启动与停止
```
cd /root/app/hadoop-3.1.0
./sbin/start-all.sh
./sbin/stop-all.sh
```

- 查看服务
```
root@ubuntu:~/app/hadoop-3.1.0# jps
23058 NameNode
23491 SecondaryNameNode
23753 ResourceManager
23225 DataNode
24427 Jps
24030 NodeManager
```
- Resource Manager http://localhost:8088
- Web UI of the NameNode daemon http://localhost:50070
- HDFS NameNode web interface http://localhost:8042
