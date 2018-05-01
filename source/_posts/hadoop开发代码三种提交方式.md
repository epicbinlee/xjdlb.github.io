
---
title: hadoop开发代码三种提交方式
date: 2018-05-01 10:37:20
tags: [列表,程序,hadoop]
categories: 程序
toc: true
mathjax: true
---

本文介绍如何在本地编写wordcount程序，在远程的hadoop集群上运行测试代码，重点介绍了hadoop本地开发后的三种提交到服务器的方式，分别涉及到了项目开发，项目测试，项目交付时期的不同提交方式。

<!-- more -->

## 新建项目

- 新建java项目
- 添加依赖
    > maven：下载设置maven，新建maven项目，在maven repository找到坐标  
    > 手动添加依赖：用户依赖，直接把hadoop/share中lib包逐个引用过来  
    > 手动添加依赖：lib依赖，将所有的jar放在一个目录下  

- 关联源代码：ctrl+单击打开api，管理源码，打开解压后的源码文件夹
    > JDK基本的源码在JDK安装路径中src.zip  
    > hadoop源码在官网下载解压后关联文件夹到eclipse

- 代码分为三个部分：主程序设置job任务，mapper，reducer
1. main
```
package com.hikvision.wc;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
public class WCJob {
	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
		// 默认加载根目录src目录下的配置文件
		Configuration conf = new Configuration();
		conf.set("fs.defaultFS", "hdfs://n1:8020");
		conf.set("yarn.resourcemanager.hotsname", "n3");
		Job job = Job.getInstance(conf);
		// 设定MR主类
		job.setJarByClass(WCJob.class);
		// 设定mapper
		job.setMapperClass(WCMapper.class);
		job.setOutputKeyClass(Text.class);
		job.setMapOutputValueClass(IntWritable.class);
		// 设定reducer
		job.setReducerClass(WCReducer.class);
		// 要分析的文件
		FileInputFormat.addInputPath(job, new Path("/wc/input/data.txt"));
		// 输出路径
		Path outPath = new Path("/wc/output");
		FileSystem fs = FileSystem.get(conf);
		if (fs.exists(outPath)) {
			fs.delete(outPath, true);
		}
		FileOutputFormat.setOutputPath(job, outPath);
		// 提交job作业
		boolean flag = job.waitForCompletion(true);
		if (flag) {
			System.out.println("job commit successfully...");
		}
	}
}
```
2. mapper
```
package com.hikvision.wc;
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.util.StringUtils;
public class WCMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
	@Override
	protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
		String str = value.toString();
		String[] strs = StringUtils.split(str, ' ');
		for (String s : strs) {
			context.write(new Text(s), new IntWritable(1));
		}
	}
}
```
3. reducer
```
package com.hikvision.wc;
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
public class WCReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
	@Override
	protected void reduce(Text text, Iterable<IntWritable> iterable, Context context) throws IOException, InterruptedException {
		int sum = 0;
		for (IntWritable i : iterable) {
			sum += i.get();
		}
		context.write(text, new IntWritable(sum));
	}
}
```

## 运行项目

- 测试数据放在src下
- 三种运行方式
    > 本地测试环境（企业开发过程中测试）  
    > 提交到服务器（测试代码的执行能力）  
    > 自动打包  
    > 手动打包  

## 提交1：不打包本地提交到远程服务器直接执行（功能开发过程）

- 没有配置文件+必要的conf设置
- 本地eclipse提交代码
    > 解压hadoop，配置环境变量  
    > 安装windows中的hadoop依赖工具win-utils的%HADOOP_HOME%\bin  
    > 拷贝hadoop源码到自己的工程中，检查包是不是报错  
    > 配置本地hosts文件  
    > 启动zkServer.sh start  
    > 启动start-all.sh(dfs yarn)  
    > 启动resource manager(RS)  
    > 测试50070，找到active的dfs节点  
    > 测试8088，找到active的resourcemanager节点  
    > 配置本地的hadoop连接  
    > 创建输入文件夹，上传数据文件  
    > 配置conf提交地址  
    > 在main中填写输入输出路径  
    > 直接以java application运行代码  

- 实验结果
```
2018-05-01 18:11:01,551 INFO  Configuration.deprecation (Configuration.java:warnOnceIfDeprecated(1243)) - session.id is deprecated. Instead, use dfs.metrics.session-id
2018-05-01 18:11:01,559 INFO  jvm.JvmMetrics (JvmMetrics.java:init(76)) - Initializing JVM Metrics with processName=JobTracker, sessionId=
2018-05-01 18:11:02,328 WARN  mapreduce.JobResourceUploader (JobResourceUploader.java:uploadFiles(64)) - Hadoop command-line option parsing not performed. Implement the Tool interface and execute your application with ToolRunner to remedy this.
2018-05-01 18:11:02,401 WARN  mapreduce.JobResourceUploader (JobResourceUploader.java:uploadFiles(171)) - No job jar file set.  User classes may not be found. See Job or Job#setJar(String).
2018-05-01 18:11:02,466 INFO  input.FileInputFormat (FileInputFormat.java:listStatus(283)) - Total input paths to process : 1
2018-05-01 18:11:02,601 INFO  mapreduce.JobSubmitter (JobSubmitter.java:submitJobInternal(198)) - number of splits:1
2018-05-01 18:11:02,776 INFO  mapreduce.JobSubmitter (JobSubmitter.java:printTokens(287)) - Submitting tokens for job: job_local2042689909_0001
2018-05-01 18:11:03,239 INFO  mapreduce.Job (Job.java:submit(1294)) - The url to track the job: http://localhost:8080/
2018-05-01 18:11:03,242 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1339)) - Running job: job_local2042689909_0001
2018-05-01 18:11:03,251 INFO  mapred.LocalJobRunner (LocalJobRunner.java:createOutputCommitter(471)) - OutputCommitter set in config null
2018-05-01 18:11:03,260 INFO  output.FileOutputCommitter (FileOutputCommitter.java:<init>(108)) - File Output Committer Algorithm version is 1
2018-05-01 18:11:03,265 INFO  mapred.LocalJobRunner (LocalJobRunner.java:createOutputCommitter(489)) - OutputCommitter is org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter
2018-05-01 18:11:03,438 INFO  mapred.LocalJobRunner (LocalJobRunner.java:runTasks(448)) - Waiting for map tasks
2018-05-01 18:11:03,445 INFO  mapred.LocalJobRunner (LocalJobRunner.java:run(224)) - Starting task: attempt_local2042689909_0001_m_000000_0
2018-05-01 18:11:03,493 INFO  output.FileOutputCommitter (FileOutputCommitter.java:<init>(108)) - File Output Committer Algorithm version is 1
2018-05-01 18:11:03,502 INFO  util.ProcfsBasedProcessTree (ProcfsBasedProcessTree.java:isAvailable(192)) - ProcfsBasedProcessTree currently is supported only on Linux.
2018-05-01 18:11:03,567 INFO  mapred.Task (Task.java:initialize(614)) -  Using ResourceCalculatorProcessTree : org.apache.hadoop.yarn.util.WindowsBasedProcessTree@5b5d72a5
2018-05-01 18:11:03,574 INFO  mapred.MapTask (MapTask.java:runNewMapper(756)) - Processing split: hdfs://n1:8020/wc/input/data.txt:0+44
2018-05-01 18:11:03,666 INFO  mapred.MapTask (MapTask.java:setEquator(1205)) - (EQUATOR) 0 kvi 26214396(104857584)
2018-05-01 18:11:03,666 INFO  mapred.MapTask (MapTask.java:init(998)) - mapreduce.task.io.sort.mb: 100
2018-05-01 18:11:03,666 INFO  mapred.MapTask (MapTask.java:init(999)) - soft limit at 83886080
2018-05-01 18:11:03,666 INFO  mapred.MapTask (MapTask.java:init(1000)) - bufstart = 0; bufvoid = 104857600
2018-05-01 18:11:03,666 INFO  mapred.MapTask (MapTask.java:init(1001)) - kvstart = 26214396; length = 6553600
2018-05-01 18:11:03,671 INFO  mapred.MapTask (MapTask.java:createSortingCollector(403)) - Map output collector class = org.apache.hadoop.mapred.MapTask$MapOutputBuffer
2018-05-01 18:11:04,185 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - 
2018-05-01 18:11:04,189 INFO  mapred.MapTask (MapTask.java:flush(1460)) - Starting flush of map output
2018-05-01 18:11:04,190 INFO  mapred.MapTask (MapTask.java:flush(1482)) - Spilling map output
2018-05-01 18:11:04,190 INFO  mapred.MapTask (MapTask.java:flush(1483)) - bufstart = 0; bufend = 70; bufvoid = 104857600
2018-05-01 18:11:04,191 INFO  mapred.MapTask (MapTask.java:flush(1485)) - kvstart = 26214396(104857584); kvend = 26214368(104857472); length = 29/6553600
2018-05-01 18:11:04,212 INFO  mapred.MapTask (MapTask.java:sortAndSpill(1667)) - Finished spill 0
2018-05-01 18:11:04,217 INFO  mapred.Task (Task.java:done(1046)) - Task:attempt_local2042689909_0001_m_000000_0 is done. And is in the process of committing
2018-05-01 18:11:04,234 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - map
2018-05-01 18:11:04,234 INFO  mapred.Task (Task.java:sendDone(1184)) - Task 'attempt_local2042689909_0001_m_000000_0' done.
2018-05-01 18:11:04,242 INFO  mapred.Task (Task.java:done(1080)) - Final Counters for attempt_local2042689909_0001_m_000000_0: Counters: 22
	File System Counters
		FILE: Number of bytes read=150
		FILE: Number of bytes written=335288
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=44
		HDFS: Number of bytes written=0
		HDFS: Number of read operations=6
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=1
	Map-Reduce Framework
		Map input records=8
		Map output records=8
		Map output bytes=70
		Map output materialized bytes=92
		Input split bytes=97
		Combine input records=0
		Spilled Records=8
		Failed Shuffles=0
		Merged Map outputs=0
		GC time elapsed (ms)=0
		Total committed heap usage (bytes)=233832448
	File Input Format Counters 
		Bytes Read=44
2018-05-01 18:11:04,243 INFO  mapred.LocalJobRunner (LocalJobRunner.java:run(249)) - Finishing task: attempt_local2042689909_0001_m_000000_0
2018-05-01 18:11:04,243 INFO  mapred.LocalJobRunner (LocalJobRunner.java:runTasks(456)) - map task executor complete.
2018-05-01 18:11:04,246 INFO  mapred.LocalJobRunner (LocalJobRunner.java:runTasks(448)) - Waiting for reduce tasks
2018-05-01 18:11:04,249 INFO  mapred.LocalJobRunner (LocalJobRunner.java:run(302)) - Starting task: attempt_local2042689909_0001_r_000000_0
2018-05-01 18:11:04,249 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1360)) - Job job_local2042689909_0001 running in uber mode : false
2018-05-01 18:11:04,250 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 100% reduce 0%
2018-05-01 18:11:04,259 INFO  output.FileOutputCommitter (FileOutputCommitter.java:<init>(108)) - File Output Committer Algorithm version is 1
2018-05-01 18:11:04,260 INFO  util.ProcfsBasedProcessTree (ProcfsBasedProcessTree.java:isAvailable(192)) - ProcfsBasedProcessTree currently is supported only on Linux.
2018-05-01 18:11:04,317 INFO  mapred.Task (Task.java:initialize(614)) -  Using ResourceCalculatorProcessTree : org.apache.hadoop.yarn.util.WindowsBasedProcessTree@368baef3
2018-05-01 18:11:04,328 INFO  mapred.ReduceTask (ReduceTask.java:run(362)) - Using ShuffleConsumerPlugin: org.apache.hadoop.mapreduce.task.reduce.Shuffle@42ca90ce
2018-05-01 18:11:04,347 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:<init>(205)) - MergerManager: memoryLimit=1987680640, maxSingleShuffleLimit=496920160, mergeThreshold=1311869312, ioSortFactor=10, memToMemMergeOutputsThreshold=10
2018-05-01 18:11:04,349 INFO  reduce.EventFetcher (EventFetcher.java:run(61)) - attempt_local2042689909_0001_r_000000_0 Thread started: EventFetcher for fetching Map Completion Events
2018-05-01 18:11:04,428 INFO  reduce.LocalFetcher (LocalFetcher.java:copyMapOutput(144)) - localfetcher#1 about to shuffle output of map attempt_local2042689909_0001_m_000000_0 decomp: 88 len: 92 to MEMORY
2018-05-01 18:11:04,446 INFO  reduce.InMemoryMapOutput (InMemoryMapOutput.java:shuffle(100)) - Read 88 bytes from map-output for attempt_local2042689909_0001_m_000000_0
2018-05-01 18:11:04,455 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:closeInMemoryFile(319)) - closeInMemoryFile -> map-output of size: 88, inMemoryMapOutputs.size() -> 1, commitMemory -> 0, usedMemory ->88
2018-05-01 18:11:04,461 INFO  reduce.EventFetcher (EventFetcher.java:run(76)) - EventFetcher is interrupted.. Returning
2018-05-01 18:11:04,462 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - 1 / 1 copied.
2018-05-01 18:11:04,462 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:finalMerge(691)) - finalMerge called with 1 in-memory map-outputs and 0 on-disk map-outputs
2018-05-01 18:11:04,482 INFO  mapred.Merger (Merger.java:merge(606)) - Merging 1 sorted segments
2018-05-01 18:11:04,482 INFO  mapred.Merger (Merger.java:merge(705)) - Down to the last merge-pass, with 1 segments left of total size: 82 bytes
2018-05-01 18:11:04,483 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:finalMerge(758)) - Merged 1 segments, 88 bytes to disk to satisfy reduce memory limit
2018-05-01 18:11:04,484 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:finalMerge(788)) - Merging 1 files, 92 bytes from disk
2018-05-01 18:11:04,484 INFO  reduce.MergeManagerImpl (MergeManagerImpl.java:finalMerge(803)) - Merging 0 segments, 0 bytes from memory into reduce
2018-05-01 18:11:04,485 INFO  mapred.Merger (Merger.java:merge(606)) - Merging 1 sorted segments
2018-05-01 18:11:04,486 INFO  mapred.Merger (Merger.java:merge(705)) - Down to the last merge-pass, with 1 segments left of total size: 82 bytes
2018-05-01 18:11:04,486 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - 1 / 1 copied.
2018-05-01 18:11:04,546 INFO  Configuration.deprecation (Configuration.java:warnOnceIfDeprecated(1243)) - mapred.skip.on is deprecated. Instead, use mapreduce.job.skiprecords
2018-05-01 18:11:04,924 INFO  mapred.Task (Task.java:done(1046)) - Task:attempt_local2042689909_0001_r_000000_0 is done. And is in the process of committing
2018-05-01 18:11:04,935 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - 1 / 1 copied.
2018-05-01 18:11:04,935 INFO  mapred.Task (Task.java:commit(1225)) - Task attempt_local2042689909_0001_r_000000_0 is allowed to commit now
2018-05-01 18:11:05,044 INFO  output.FileOutputCommitter (FileOutputCommitter.java:commitTask(535)) - Saved output of task 'attempt_local2042689909_0001_r_000000_0' to hdfs://n1:8020/wc/output/_temporary/0/task_local2042689909_0001_r_000000
2018-05-01 18:11:05,051 INFO  mapred.LocalJobRunner (LocalJobRunner.java:statusUpdate(591)) - reduce > reduce
2018-05-01 18:11:05,052 INFO  mapred.Task (Task.java:sendDone(1184)) - Task 'attempt_local2042689909_0001_r_000000_0' done.
2018-05-01 18:11:05,060 INFO  mapred.Task (Task.java:done(1080)) - Final Counters for attempt_local2042689909_0001_r_000000_0: Counters: 29
	File System Counters
		FILE: Number of bytes read=366
		FILE: Number of bytes written=335380
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=44
		HDFS: Number of bytes written=32
		HDFS: Number of read operations=9
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=3
	Map-Reduce Framework
		Combine input records=0
		Combine output records=0
		Reduce input groups=5
		Reduce shuffle bytes=92
		Reduce input records=8
		Reduce output records=5
		Spilled Records=8
		Shuffled Maps =1
		Failed Shuffles=0
		Merged Map outputs=1
		GC time elapsed (ms)=28
		Total committed heap usage (bytes)=267386880
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Output Format Counters 
		Bytes Written=32
2018-05-01 18:11:05,060 INFO  mapred.LocalJobRunner (LocalJobRunner.java:run(325)) - Finishing task: attempt_local2042689909_0001_r_000000_0
2018-05-01 18:11:05,061 INFO  mapred.LocalJobRunner (LocalJobRunner.java:runTasks(456)) - reduce task executor complete.
2018-05-01 18:11:05,253 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 100% reduce 100%
2018-05-01 18:11:06,254 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1378)) - Job job_local2042689909_0001 completed successfully
2018-05-01 18:11:06,267 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1385)) - Counters: 35
	File System Counters
		FILE: Number of bytes read=516
		FILE: Number of bytes written=670668
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=88
		HDFS: Number of bytes written=32
		HDFS: Number of read operations=15
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=4
	Map-Reduce Framework
		Map input records=8
		Map output records=8
		Map output bytes=70
		Map output materialized bytes=92
		Input split bytes=97
		Combine input records=0
		Combine output records=0
		Reduce input groups=5
		Reduce shuffle bytes=92
		Reduce input records=8
		Reduce output records=5
		Spilled Records=16
		Shuffled Maps =1
		Failed Shuffles=0
		Merged Map outputs=1
		GC time elapsed (ms)=28
		Total committed heap usage (bytes)=501219328
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Input Format Counters 
		Bytes Read=44
	File Output Format Counters 
		Bytes Written=32
job commit successfully...
```

- 查看结果
```
aaa	2
apple	3
ooo	1
ttt	1
yyy	1
```

## 提交2：打包到本地，直接运行（项目性能测试）

- 配置文件+必要的conf设置
- 使用配置文件
    > 拷贝四个配置文件到源代码下面  
    ```
    core-site.xml
    hdfs-site.xml
    mapred-site.xml
    yarn-site.xml
    ```
    > 在主代码中指定打包的位置，并注释掉代码配置  
    ```
    // conf.set("fs.defaultFS", "hdfs://n1:8020");
    // conf.set("yarn.resourcemanager.hotsname", "n3");
    conf.set("mapred.jar", "D:\\mr\\wc.jar");
    ```
    > 手动打jar：项目右键 > export > > java jar file > 指定路径  
    > 选择main calss  
    > 运行下java程序  
    > 刷新 http://n3:8088/cluster 是不是有新的任务  
    > 运行任务时，常见的报错如下
    > [解决链接1:conf设置夸平台提交](https://stackoverflow.com/questions/24075669/mapreduce-job-fail-when-submitted-from-windows-machine)  
    > [解决链接2:修改源码](http://zy19982004.iteye.com/blog/2031172)  
    ```
    问题：
    org.apache.hadoop.util.Shell$ExitCodeException: /bin/bash: line 0: fg: no job control
    解决1：
    这是由于跨平台造成的，经过Google搜索口在StackOverflow上发现答案
    conf.set("mapreduce.app-submission.cross-platform", "true");
    解决2：
    需要手动修改hadoop源码，目前还没有弄明白
    ```
    > 处理后，现在的main如下  
    ```
    // 默认加载根目录src目录下的配置文件
    Configuration conf = new Configuration();
    // conf.set("fs.defaultFS", "hdfs://n1:8020");
    // conf.set("yarn.resourcemanager.hotsname", "n3");
    conf.set("mapreduce.app-submission.cross-platform", "true");
    conf.set("mapred.jar", "D:\\mr\\wc.jar");
    ```
    > 以java application的方式运行程序  
    > 在控制台和active节点 http://n3:8088/cluster 查看运行的日志，WebUI会显示提交的任务  
    > 在eclipse-hadoop文件系统查看是不是有数据输出  

## 提交3：打包到本地，手动上传（项目上线时候）

- 配置文件+删除不必要的conf设置
- 屏蔽不必要的cond指定
    ```
    // 默认加载根目录src目录下的配置文件
    Configuration conf = new Configuration();
    // conf.set("fs.defaultFS", "hdfs://n1:8020");
    // conf.set("yarn.resourcemanager.hotsname", "n3");
    // conf.set("mapreduce.app-submission.cross-platform", "true");
    // conf.set("mapred.jar", "D:\\mr\\wc.jar");
    ```
- 手动打包，指定main class
- 通过命令运行程序
    ```
    hadoop jar jar路径 程序的入口(主程序的入口)
    hadoop jar wc-1.jar com.hikvision.wc.WCJob
    ```
- 查看输出和webUI信息
