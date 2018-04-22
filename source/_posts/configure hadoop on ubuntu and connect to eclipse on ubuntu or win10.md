
---
title: configure hadoop on ubuntu and connect to eclipse on ubuntu or win10
date: 2018-04-22 12:49:06
tags: [列表,eclipse,hadoop,configuration]
categories: configuration
toc: true
mathjax: true
---

This article describes how to configure hadoop2.7.6 on ubuntu and connect to hadoop2.7.6 using eclipse on ubuntu and win10 respectively.

<!-- more -->

## **prerequisites**
- **server**
1. win10
2. vmware workstation pro 12
3. Ubuntu 16.04.4 LTS
4. hadoop 2.7.6 [download](http://hadoop.apache.org/releases.html)

- **ubuntu clinet**
1. eclipse neon [download](http://www.eclipse.org/downloads/packages/release/Neon/3)
2. hadoop-eclipse-plugin-2.7.2.jar [download](https://download.csdn.net/download/tondayong1981/9432425)

- **win10 client**
1. eclipse neon [download](http://www.eclipse.org/downloads/packages/release/Neon/3)
2. hadoop-eclipse-plugin-2.7.2.jar [download](https://download.csdn.net/download/tondayong1981/9432425)

## **pretreatment for ubuntu virtual machine**
- **enable the user-passwd input box on the login screen**
```
sudo passwd root
su root
cd /usr/share/lightdm/lightdm.conf.d/
vim 50-unity-greeter.conf
# add
user-session=ubuntu
greeter-show-manual-login=true
all-guest=false
# reboot
reboot
# login in ubuntu with root and get a error report
vim /root/.profile
# locate to
mesg n || true
# change to
tty -s && mesg n || true
```
- **configure jdk for ubuntu**
- jdk 1.8 [download](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
```
export JAVA_HOME=/root/app/jdk1.8.0_171
export JRE_HOME=/root/app/jdk1.8.0_171/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
source /etc/profile
java -version
```

## **configure hadoop2.7.6**
- **append *JAVA_HOME* to stat script**
```
step 1:
vim /root/app/hadoop/etc/hadoop/hadoop-env.sh
# export JAVA_HOME=${JAVA_HOME}
export JAVA_HOME=/root/app/jdk1.8.0_171
###########################################
step 2:
vim /root/app/hadoop/etc/hadoop/yarn-env.sh
# some Java parameters
# export JAVA_HOME=/home/y/libexec/jdk1.6.0/
export JAVA_HOME=/root/app/jdk1.8.0_171
```

- **configure core-site.xml, hdfs-site.xml,  mapred-site.xml, yarn-site.xml**
```
step 1:
vim /root/app/hadoop/etc/hadoop/core-site.xml
<configuration>
	 <property>
	    <name>fs.default.name</name>
		<value>hdfs://localhost:9000</value>
	</property>
	<property>
		<name>hadoop.tmp.dir</name>
		<value>/root/app/hadoop/tmp</value>
	</property>
</configuration>
###########################################
step 2:
vim /root/app/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
	<property>
		<name>dfs.name.dir</name>
		<value>/root/app/hadoop/hdfs/name</value>
	</property>
	<property>
		<name>dfs.data.dir</name>
		<value>/root/app/hadoop/hdfs/data</value>
	</property>
   <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
	<property>
		<name>dfs.replication</name>
		<value>1</value>
		<description>defult 3, less than numbers of datanode</description>
	</property>
</configuration>
###########################################
step 3:
vim /root/app/hadoop/etc/hadoop/mapred-site.xml
<configuration>
	<property>
		<name>mapreduce.framework.name</name>
		<value>yarn</value>
	</property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>localhost:10020</value>
        <description>MapReduce JobHistory Server IPC host:port</description>
    </property>
</configuration>
###########################################
step 4:
vim /root/app/hadoop/etc/hadoop/yarn-site.xml
<configuration>
	<property>
			<name>yarn.nodemanager.aux-services</name>
			<value>mapreduce_shuffle</value>
	</property>
	<property>
			<name>yarn.resourcemanager.webapp.address</name>
			<value>localhost:8099</value>
	</property>
</configuration>
```

- **create floder for hadoop work directory**
```
cd /root/app/hadoop
mkdir hdfs -p hdfs/data hdfs/name
mkdir tmp
```

- **format hdfs and start/stop hadoop**
1. format hdfs
```
# keep all hadoop process stopped
./sbin/stop-all.sh
# remove tmp directory
rm -rdf tmp/
# format hdfs only once
bin/hdfs namenode -format
# see if the format is successful
tree hdfs/
```
2. start/stop hadoop
```
# start hadoop
./sbin/start-all.sh
root@ubuntu:~/app/hadoop# jps
63809 Jps
63474 NodeManager
62950 DataNode
63335 ResourceManager
62775 NameNode
63163 SecondaryNameNode
# stop hadoop
./sbin/stop-all.sh
```

## **connect to hadoop with eclipse**
- **install plugin in eclipse on ubuntu**
```
1 copy to hadoop-eclipse-plugin-2.7.2.jar to ${eclipse_home}/dropins;
2 open eclipse;
3 open menu > windows > show view > other > mapreduce tools > map/reduce locations;
4 map/reduce locations > right click > edit hadoop location;
location name: XXX
map/reduce master:
    host: localhost
    port: 50020
dfs master:
    host: localhost
    port: 9000
5 open dfs locations, you will find the file in hdfs.
```
- **install plugin in eclipse on win10**
```
1 on win10, your eclipse serves as a clinet, you can connect your server with ip, so you should firstly replace *localhost* with your server ip in all etc files, such as core-site.xml, hdfs-site.xml,  mapred-site.xml, yarn-site.xml;
2 repeat the step 1,2,3,4 above;
3 map/reduce locations > right click > edit hadoop location > advace parameters, replace *hadoop.tmp.dir* with your own address in /hdfs-site.xml;
4 enjoy the local developing and the remote debuging.
```
