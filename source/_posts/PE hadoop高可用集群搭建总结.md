
---
title: PE hadoop高可用集群搭建总结
date: 2018-04-30 18:26:25
tags: [列表,hadoop,配置]
categories: configuration
toc: true
mathjax: true
---

本文简单记录生产环境中的hadoop高可用集群搭建总结。

<!-- more -->


## hdfs ha理论总结

- NN内存受到限制：federation
- NN单点故障：edits和fsimage原理，在没有格式化的NN上standby操作
- edits记录日志文件，保障一致性，交给第三方JNs来管理，奇数个，不用NFS不可靠
- zookeeper，奇数个，它的ZKFC心跳监控NN；管理和切换zkfc

## hdfs ha搭建总结

- edits交给JN,手动启动三个JN
- 格式化一台NN，并启动这一台
- 另外一台NN执行同步standby
- zookeeper进行操作
- 启动zk集群，三台，最好在xshell下面一起启动，并且查看状态status
- 格式化zk
- 启动dfs

## mr yarn理论

- 四个阶段：split，map,shuffle,reduce, 最小的MR程序包含了前面两个
- split块
- map task按行读<K,V>排序
- 分区partition，memory buffer，sort & combine（手动实现，不能代替reduce，可以提升效率）
- reduce<K,V>迭代器取数据

## 整合mr到hadoop，实现RS ha

- 先停止hdfs
- 配置mr，配置yarn高可用
- resource manager需要单独启动
