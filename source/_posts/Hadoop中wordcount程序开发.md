
---
title: hadoop中wordcount程序开发
date: 2018-04-19 13:09:22
tags: [列表,maven,hadoop]
categories: 开发
toc: true
mathjax: true
---

本文介绍如何利用java和hadoop组件开发wordcount程序。

<!-- more -->

## 开发与测试环境

- windows
- eclipse
- maven，常见的组件如下：
1. Apache Hadoop Common 3.1
2. Apache Hadoop Client Aggregator 3.1
3. Hadoop Core 1.2
4. Apache Hadoop HDFS 3.1
5. Apache Hadoop MapReduce Core 3.1
- ubuntu中hadoop单机模式，搭建过程参考: [如何hadoop单机版](https://leebin.top/2018/04/18/ubuntu%E4%B8%ADhadoop%E5%8D%95%E6%9C%BA%E6%A8%A1%E5%BC%8F%E5%92%8C%E4%BC%AA%E5%88%86%E5%B8%83%E5%BC%8F%E6%90%AD%E5%BB%BA/)

## 添加依赖后maven报错

- 报错
```
Buiding Hadoop with Eclipse / Maven - Missing artifact jdk.tools:jdk.tools:jar:1.6
```

- 解决
```
# cmd
C:\Users\BinLee>java -version
java version "1.8.0_144"
Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
# 添加下面的依赖到maven的pom.xml
<dependency>
    <groupId>jdk.tools</groupId>
    <artifactId>jdk.tools</artifactId>
    <version>1.8.0_144</version>
    <scope>system</scope>
    <systemPath>${JAVA_HOME}/lib/tools.jar</systemPath>
</dependency>
```

## wordcount程序开发

- pom.xml
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.jordiburgos</groupId>
	<artifactId>wordcount</artifactId>
	<packaging>jar</packaging>
	<version>1.0-SNAPSHOT</version>
	<name>wordcount</name>
	<url>http://jordiburgos.com</url>
	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>
	<repositories>
		<repository>
			<id>cloudera</id>
			<url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
		</repository>
	</repositories>
	<dependencies>
		<dependency>
			<groupId>org.apache.hadoop</groupId>
			<artifactId>hadoop-common</artifactId>
			<version>2.2.0</version>
		</dependency>
		<dependency>
			<groupId>org.apache.hadoop</groupId>
			<artifactId>hadoop-core</artifactId>
			<version>1.2.1</version>
		</dependency>
		<dependency>
			<groupId>jdk.tools</groupId>
			<artifactId>jdk.tools</artifactId>
			<version>1.7</version>
			<scope>system</scope>
			<systemPath>${java.home}/../lib/tools.jar</systemPath>
		</dependency>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>3.8.1</version>
			<scope>test</scope>
		</dependency>
	</dependencies>
	<build>
		<plugins>
			<plugin>
				<artifactId>maven-assembly-plugin</artifactId>
				<version>2.4</version>
				<executions>
					<execution>
						<id>distro-assembly</id>
						<phase>package</phase>
						<goals>
							<goal>single</goal>
						</goals>
						<configuration>
							<descriptors>
								<descriptor>assembly.xml</descriptor>
							</descriptors>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
</project>
```

- wordcount.java
```
package com.jordiburgos;
import java.io.IOException;
import java.util.*;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
public class WordCount {
	public static class Map extends Mapper<LongWritable, Text, Text, IntWritable> {
		private final static IntWritable one = new IntWritable(1);
		private Text word = new Text();
		public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
			String line = value.toString();
			StringTokenizer tokenizer = new StringTokenizer(line);
			while (tokenizer.hasMoreTokens()) {
				word.set(tokenizer.nextToken());
				context.write(word, one);
			}
		}
	}
	public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {
		public void reduce(Text key, Iterable<IntWritable> values, Context context)
				throws IOException, InterruptedException {
			int sum = 0;
			for (IntWritable val : values) {
				sum += val.get();
			}
			context.write(key, new IntWritable(sum));
		}
	}
	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		Job job = new Job(conf, "wordcount");
		job.setJarByClass(WordCount.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		job.setMapperClass(Map.class);
		job.setReducerClass(Reduce.class);
		job.setInputFormatClass(TextInputFormat.class);
		job.setOutputFormatClass(TextOutputFormat.class);
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		job.waitForCompletion(true);
	}
}
```

## 使用maven打包程序

- 打包命令
```
项目右键>run as>maven build
```

- 打包后jar的结构
```
C:.
└─wordcount
    ├─com
    │  └─jordiburgos
    └─META-INF
        └─maven
            └─com.jordiburgos
                └─wordcount
```

## 在hadoop上运行程序

- 上传待分析的文本到hdfs
```
# 本地创建input文件夹和a.txt文件
cd /root/app/hadoop-3.1.0
mkdir input
vim a.txt
#
# 创建文件夹
hadoop fs -mkdir hdfs://localhost:9001/tmp
#
# 上传文件到hdfs
hadoop fs -put /root/app/hadoop-3.1.0/input hdfs://127.0.0.1:9001/tmp
```

- 运行jar程序
```
cd /root/app/hadoop-3.1.0
bin/hadoop jar wordcount.jar com.jordiburgos.WordCount hdfs://localhost:9001/tmp/input/ file:///root/app/hadoop-3.1.0/output/
```

- 在linux中查看输出文件
```
cd /root/app/hadoop-3.1.0/output
root@ubuntu:~/app/hadoop-3.1.0/output# ls
part-r-00000  _SUCCESS
root@ubuntu:~/app/hadoop-3.1.0/output# cat part-r-00000
0000	1
aaaa	1
ddfh	1
ff	1
ggg	1
hj	1
iiiii	1
sss	1
```
