
---
title: zookeeper working mechanism and installation
date: 2018-04-24 14:55:35
tags: [列表,zookdata,configuration,hbase]
categories: configuration
toc: true
mathjax: true
---

This article describes the basic working principle and installation process of zookeeper.

<!-- more -->

## zookeeper working mechanism

- zookeeper is a high-performance application coordination server that is mainly used to maintain a file system-like namespace.
- zookeeper itself contains 2n+1 servers, and their roles are divided into leader and follower.
- zookeeper maintains multiple server services and maintains data consistency to ensure that clients connecting to any server can get consistent data services.
- zookeeper's nodes have 4 life cycles.
```
PERSISTENT (persistent node)
PERSISTENT_SEQUENTIAL (Sequential automatic numbering of persistent nodes, this node automatically adds 1 based on the number of existing nodes)
EPHEMERAL (temporary node, client session timeout such nodes will be automatically deleted)
EPHEMERAL_SEQUENTIAL (temporary automatic numbering node)
```

## install and configure zookeeper

- download > extract > configure > start/stop > test
- configure
```
root@ubuntu:~/app/zookeeper# ll
total 1596
drwxr-xr-x 10 1001 1001    4096 Mar 23  2017 ./
drwxr-xr-x 13 root root    4096 Apr 23 23:50 ../
drwxr-xr-x  2 1001 1001    4096 Mar 23  2017 bin/
-rw-rw-r--  1 1001 1001   84725 Mar 23  2017 build.xml
drwxr-xr-x  2 1001 1001    4096 Mar 23  2017 conf/
drwxr-xr-x 10 1001 1001    4096 Mar 23  2017 contrib/
drwxr-xr-x  2 1001 1001    4096 Mar 23  2017 dist-maven/
drwxr-xr-x  6 1001 1001    4096 Mar 23  2017 docs/
-rw-rw-r--  1 1001 1001    1709 Mar 23  2017 ivysettings.xml
-rw-rw-r--  1 1001 1001    5691 Mar 23  2017 ivy.xml
drwxr-xr-x  4 1001 1001    4096 Mar 23  2017 lib/
-rw-rw-r--  1 1001 1001   11938 Mar 23  2017 LICENSE.txt
-rw-rw-r--  1 1001 1001    3132 Mar 23  2017 NOTICE.txt
-rw-rw-r--  1 1001 1001    1770 Mar 23  2017 README_packaging.txt
-rw-rw-r--  1 1001 1001    1585 Mar 23  2017 README.txt
drwxr-xr-x  5 1001 1001    4096 Mar 23  2017 recipes/
drwxr-xr-x  8 1001 1001    4096 Mar 23  2017 src/
-rw-rw-r--  1 1001 1001 1456729 Mar 23  2017 zookeeper-3.4.10.jar
-rw-rw-r--  1 1001 1001     819 Mar 23  2017 zookeeper-3.4.10.jar.asc
-rw-rw-r--  1 1001 1001      33 Mar 23  2017 zookeeper-3.4.10.jar.md5
-rw-rw-r--  1 1001 1001      41 Mar 23  2017 zookeeper-3.4.10.jar.sha1
#==============================
-rw-rw-r--  1 1001 1001  535 Mar 23  2017 configuration.xsl
-rw-rw-r--  1 1001 1001 2161 Mar 23  2017 log4j.properties
-rw-rw-r--  1 1001 1001  922 Mar 23  2017 zoo_sample.cfg
root@ubuntu:~/app/zookeeper/conf# cp zoo_sample.cfg zoo.cfg
root@ubuntu:~/app/zookeeper/conf# ll
total 24
drwxr-xr-x  2 1001 1001 4096 Apr 24 00:17 ./
drwxr-xr-x 10 1001 1001 4096 Mar 23  2017 ../
-rw-rw-r--  1 1001 1001  535 Mar 23  2017 configuration.xsl
-rw-rw-r--  1 1001 1001 2161 Mar 23  2017 log4j.properties
-rw-r--r--  1 root root  922 Apr 24 00:17 zoo.cfg
-rw-rw-r--  1 1001 1001  922 Mar 23  2017 zoo_sample.cfg
#------------------------------
vim zoo.cfg
mkdir -p /root/app/zookeeper/zookdata
# dataDir=/tmp/zookeeper
dataDir=/root/app/zookeeper/zookdata
# append the following:
server.1=192.168.231.150:2888:3888
#------------------------------
root@ubuntu:~/app/zookeeper/zookdata# pwd
/root/app/zookeeper/zookdata
root@ubuntu:~/app/zookeeper/zookdata# touch myid && echo 1 > myid
root@ubuntu:~/app/zookeeper/zookdata# cat myid
1
#==============================
scp the zookeeper to other server
reset myid file in zookeeper on other server
#==============================
```

## start/stop zookeeper
- start zookeeper
```
root@ubuntu:~/app/zookeeper/bin# ll
total 52
drwxr-xr-x  2 1001 1001 4096 Apr 24 00:35 ./
drwxr-xr-x 11 1001 1001 4096 Apr 24 00:19 ../
-rwxr-xr-x  1 1001 1001  232 Mar 23  2017 README.txt*
-rwxr-xr-x  1 1001 1001 1937 Mar 23  2017 zkCleanup.sh*
-rwxr-xr-x  1 1001 1001 1056 Mar 23  2017 zkCli.cmd*
-rwxr-xr-x  1 1001 1001 1534 Mar 23  2017 zkCli.sh*
-rwxr-xr-x  1 1001 1001 1628 Mar 23  2017 zkEnv.cmd*
-rwxr-xr-x  1 1001 1001 2696 Mar 23  2017 zkEnv.sh*
-rwxr-xr-x  1 1001 1001 1089 Mar 23  2017 zkServer.cmd*
-rwxr-xr-x  1 1001 1001 6773 Mar 23  2017 zkServer.sh*
-rw-r--r--  1 root root 5056 Apr 24 00:35 zookeeper.out
#------------------------------
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Usage: ./zkServer.sh {start|start-foreground|stop|restart|status|upgrade|print-cmd}
#------------------------------
root@ubuntu:~/app/zookeeper/bin# ./zkServer.sh start
zookeeper JMX enabled by default
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
#------------------------------
root@ubuntu:~/app/zookeeper/bin# jps
38113 Jps
34545 HQuorumPeer
34757 HRegionServer
12550 NodeManager
12408 ResourceManager
12024 DataNode
34618 HMaster
12235 SecondaryNameNode
11852 NameNode
#------------------------------
root@ubuntu:~/app/zookeeper/bin# ./zkServer.sh status
zookeeper JMX enabled by default
Using config: /root/app/zookeeper/bin/../conf/zoo.cfg
Mode: standalone
```

- use zookeeper
```
root@ubuntu:~/app/zookeeper/bin# ./zkCli.sh
Connecting to localhost:2181
...
2018-04-24 00:40:32,972 [myid:] - INFO  [main:Environment@100] - Client
...
2018-04-24 00:40:32,984 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2018-04-24 00:40:32,984 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
...
WatchedEvent state:SyncConnected type:None path:null
#------------------------------
[zk: localhost:2181(CONNECTED) 0] help
zookeeper -server host:port cmd args
	stat path [watch]
	set path data [version]
	ls path [watch]
	delquota [-n|-b] path
	ls2 path [watch]
	setAcl path acl
	setquota -n|-b val path
	history
	redo cmdno
	printwatches on|off
	delete path [version]
	sync path
	listquota path
	rmr path
	get path [watch]
	create [-s] [-e] path data acl
	addauth scheme auth
	quit
	getAcl path
	close
	connect host:port
#------------------------------
[zk: localhost:2181(CONNECTED) 1] create /data_test 'data_test'       
Created /data_test
[zk: localhost:2181(CONNECTED) 2] ls /
[data_test, zookeeper, hbase]
[zk: localhost:2181(CONNECTED) 3] get /data_test
data_test
cZxid = 0x75
ctime = Tue Apr 24 00:42:11 PDT 2018
mZxid = 0x75
mtime = Tue Apr 24 00:42:11 PDT 2018
pZxid = 0x75
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 9
numChildren = 0
#------------------------------
[zk: localhost:2181(CONNECTED) 4] create /data_test/dir_2 '123_value'
Created /data_test/dir_2
[zk: localhost:2181(CONNECTED) 5] get /data_test
data_test
cZxid = 0x75
ctime = Tue Apr 24 00:42:11 PDT 2018
mZxid = 0x75
mtime = Tue Apr 24 00:42:11 PDT 2018
pZxid = 0x76
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 9
numChildren = 1
#------------------------------
[zk: localhost:2181(CONNECTED) 6] quit
Quitting...
2018-04-24 00:47:19,034 [myid:] - INFO  [main:zookeeper@684] - Session: 0x162f5c0c60f0007 closed
2018-04-24 00:47:19,037 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@519] - EventThread shut down for session: 0x162f5c0c60f0007
```

## view the log
- where is the log?
```
root@ubuntu:~/app/zookeeper/bin# ll
total 52
drwxr-xr-x  2 1001 1001 4096 Apr 24 00:35 ./
drwxr-xr-x 11 1001 1001 4096 Apr 24 00:19 ../
-rwxr-xr-x  1 1001 1001  232 Mar 23  2017 README.txt*
-rwxr-xr-x  1 1001 1001 1937 Mar 23  2017 zkCleanup.sh*
...
-rw-r--r--  1 root root 5056 Apr 24 00:35 zookeeper.out
```
