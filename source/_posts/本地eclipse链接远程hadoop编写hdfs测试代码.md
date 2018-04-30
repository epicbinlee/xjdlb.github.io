
---
title: 本地eclipse链接远程hadoop编写hdfs测试代码
date: 2018-04-30 15:45:35
tags: [列表,hadoop,hdfs,eclipse]
categories: 代码
toc: true
mathjax: true
---

本文介绍如何使用eclipse插件连接远程的hadoop，并且编写hdfs测试代码。

<!-- more -->

## 开发环境

- local: win10 + eclipse neon + hadoop-eclipse-2.7.3.jar
- remote: hadoop 2.7.6 + hdfs namenode ha 架构 + yarn resource manager ha 架构

## 本地eclipse连接远程的hadoop集群

- 后面所有开发的前提是windows用户名必须为root，win+x+G > 本地用户和组 > 用户 > 修改系统的用户名为root
- 上面的步骤，我没有成功，后来重新安装系统设置为root用户
- 安装hadoop-eclipse插件，copy jar到插件目录，启动，选择windows > show view > other > hadoop/mr
- 需要在windows本地安装配置和服务器相同版本的hadoop，并且下载关键字为<hadoo2.7.3的hadoop.dll和winutils.exe>的组件放在本地hadoop/bin下
- 在MR locations窗口下配置连接远程hadoop服务器，其中dfs master的端口为 50070 webUI能够访问的且显示为active的端口
- 比如：我的n2:50070 webUI上面显示8020端口 active, 所以hadoop配置为8020
- 暂时没有用到MR，所以默认就好
- 完成上述步骤即可连接远程服务器成功
- 可以创建文件进行测试：eclipse窗口创建，webUI显示，或者终端上使用hdfs shell查看文件列表

## 创建项目手动导入依赖包

- 创建项目，直接常见一个Java项目；不着急创建hadoop/mapreduce项目
- 手动添加依赖；不着急使用maven构建项目
- build path > libraries窗口 > add library > user library > user libraries > new
- name随意hadoop2.7.6 > and external jars
- 导入hadoop安装路径下面的C:\app2\hadoop-2.7.6\share\hadoop下面全部组件的lib下面的所有jars
- 最后可以看到窗口有了外部依赖hadoop2.7.6
- 最后还需要以上面的方式导入junit测试包

## 编写连接hdfs的测试代码

- 代码文件为/hdfs-test/src/com/hik/hdfs/HdfsDemo.java，下面的代码包含了连接, 创建文件夹，上传下载文件，合并小文件，下载小文件等操作，简单实现网盘的功能
```
package com.hik.hdfs;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.apache.commons.io.FileUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
public class HdfsDemo {
	FileSystem fs;
	Configuration configuration;
	@Before
	public void begin() throws Exception {
		// load configuration file from src
		configuration = new Configuration();
		
		// configuration.set("fs.defaultFS", "hdfs://n2:8020");
		
		fs = FileSystem.get(configuration);
	}
	@After
	public void end() throws Exception {
		fs.close();
	}
	@Test
	public void mkdir() throws Exception {
		Path path = new Path("/tmp_innerConfig");
		boolean newdir = fs.mkdirs(path);
		System.out.println(newdir);
	}
	@Test
	public void upload() throws IOException {
		Path path = new Path("/tmp/a2.txt");
		FSDataOutputStream outputStream = fs.create(path);
		FileUtils.copyFile(new File("D:\\test.txt"), outputStream);
	}
	@Test
	public void list() throws FileNotFoundException, IOException {
		Path path = new Path("/tmp/");
		FileStatus[] listStatus = fs.listStatus(path);
		for (FileStatus x : listStatus) {
			String str = x.getPath() + "--" + x.getLen() + "--" + x.getAccessTime();
			System.out.println(str);
		}
	}
	@Test
	public void uploadSmalltoBig() throws Exception {
		Path path = new Path("/seq.txt");
		@SuppressWarnings("deprecation")
		Writer writer = SequenceFile.createWriter(fs, configuration, path, Text.class, Text.class);
		File file = new File("D:\\file");
		for (File f : file.listFiles()) {
			Text name = new Text(f.getName());
			Text content = new Text(FileUtils.readFileToString(f, "UTF-8"));
			writer.append(name, content);
		}
	}
	@Test
	public void downloadBig() throws Exception {
		Path path = new Path("/seq.txt");
		@SuppressWarnings({ "resource", "deprecation" })
		SequenceFile.Reader reader = new SequenceFile.Reader(fs, path, configuration);
		Text key = new Text();
		Text value = new Text();
		while (reader.next(key, value)) {
			System.out.println(key);
			System.out.println(value);
		}
	}
}
```

## 运行测试程序

- 配置本地windows的hosts文件，直接用everything搜索找到c盘下面的hosts,C:\Windows\System32\drivers\etc\hosts, 加入ip和主机名的映射关系
```
192.168.44.100 n1
192.168.44.101 n2
192.168.44.102 n3
192.168.44.103 n4
```
- 运行代码前，需要导入连接先关的配置文件，将hadoop/etc/hadoop下的hdfs-site.xml和core-site.xml拷贝到src文件夹下，直接在eclipse里面粘贴
- 上面的步骤也可以在程序的configuration中设置对应的rpc接口地址
- 直接在函数名上右键run as > junit test 即可
- 如果成功绿色状态，查看hdfs文件系统是不是生成相应的文件