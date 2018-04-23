
---
title: write wordcount program on eclipse and run on hadoop in win10
date: 2018-04-23 14:36:16
tags: [列表,coding,configuration,hadoop]
categories: configuration
toc: true
mathjax: true
---

This article describes how to write the wordcount program on eclipse and run it on local hadoop.

<!-- more -->

## **prerequisites**

- **server**
1. win10
2. hadoop 2.7.6

- **client**
1. win10
2. eclipse neon
3. hadoop-eclipse-plugin-2.7.2.jar

## **create project and coding**

- **create project**
```
new > other > map reduce program > fix the boxes with name, ${HADOOP_HOME} > finish
```

- **coding**
```
package com.hikvision.bigdata.hadoop.hadoop_wordcount;
import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.log4j.BasicConfigurator;
/**
 * wordcount
 */
public class WordCount {
	public static void main(String[] args) throws Exception {
		BasicConfigurator.configure();
		System.out.println("Hello World!");
		Configuration conf = new Configuration();
		@SuppressWarnings("deprecation")
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
}
```

## **configure program**

- **configure hadoop**
```
step 1:
core-site.xml
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
hdfs-site.xml
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
mapred-site.xml
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
yarn-site.xml
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

- **format namenode**
```
cd bin
hdfs namenode -format
# format only once
```

- **start hadoop and upload data to hdfs**
```
cd ${HADOOP_HOME}
input cmd to open cmd line
cd sbin
start-all.cmd
#
#
hadoop fs -mkdir /data
hadoop fs -put D:\a.txt /data/a.txt
```
- **configure input and output path for program in eclipse**
```
1 project name > right clieck > run as > run configuration > java application > new
2 fix the boxes with the program name, main class, run name, and arguments
3 the arguments as follows:
hdfs://localhost:9000/data/a.txt hdfs://localhost:9000/data/output
```

## **run program**

- **precondition**
1. delete the output floder on hdfs
2. data is ready
3. input/output path is configured in eclipse
2. hadoop is running

- **run program**
```
project name > right clieck > run as > run on hadoop > select the main class > enjoy the ouput
```
