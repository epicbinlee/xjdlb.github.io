
---
title: MR实例温度
date: 2018-05-01 22:52:09
tags: [列表,mapreduce,hadoop]
categories: 开发
toc: true
mathjax: true
---

本文介绍如何分析具体的MR实例。

<!-- more -->

## 数据与需求

- 数据

    ```
    1949-10-01 14:21:02 34c
    1949-10-02 14:01:02 36c
    1950-01-01 11:21:02 32c
    1950-10-01 12:21:02 37c
    1951-12-01 12:21:02 23c
    1950-10-02 12:21:02 41c
    1950-10-03 12:21:02 27c
    1951-07-01 12:21:02 45c
    1951-07-02 12:21:02 46c
    1951-07-03 12:21:03 47c
    ```

- 需求

    ```
    输出：得出每个年月下，温度最高的前两天
    年月：升序
    温度：降序
    ```

- 技术点分析

    ```
    sort需要进行二次排序，需要从写sort方法
    reduce个数设定为3个，可能有%3操作，进行负载均衡
    全部的MR模型中包含了map,reduce,part,sort,group,combine
    ```

## 写代码

- 代码涉及到了MapReduce的整个生命周期
- 每个周期的代码如下

    > TQJob  

    ```
    package com.hikvision.tq;
    import org.apache.hadoop.conf.Configuration;
    import org.apache.hadoop.fs.FileSystem;
    import org.apache.hadoop.fs.Path;
    import org.apache.hadoop.io.IntWritable;
    import org.apache.hadoop.mapreduce.Job;
    import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
    import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
    public class TQJob {
        public static void main(String[] args) throws Exception {
            // 默认加载根目录src目录下的配置文件
            Configuration conf = new Configuration();
            // 运行方式1：手动指定提交服务器的地址
            // conf.set("fs.defaultFS", "hdfs://n1:8020");
            // conf.set("yarn.resourcemanager.hotsname", "n3");
            // 运行方式2：使用配置文件指定，屏蔽上面的手动指定,报错的需要指定跨平台，指定本地jar的位置
            conf.set("mapreduce.app-submission.cross-platform", "true");
            conf.set("mapred.jar", "D:\\mr\\tq.jar");
            // 运行方式3：手动上传到服务器上，屏蔽上的面的conf指定
            // System.setProperty("HADOOP_USER_NAME", "root");
            // 开始job相关的设定
            Job job = Job.getInstance(conf);
            // 设定MR主类
            job.setJarByClass(TQJob.class);
            // 设定mapper
            job.setMapperClass(TQMapper.class);
            job.setOutputKeyClass(Weather.class);
            job.setMapOutputValueClass(IntWritable.class);
            // 设定reducer
            job.setReducerClass(TQReducer.class);
            job.setPartitionerClass(TQPartition.class);
            job.setSortComparatorClass(TQSort.class);
            job.setGroupingComparatorClass(TQGroup.class);
            job.setNumReduceTasks(3);
            // 要分析的文件
            FileInputFormat.addInputPath(job, new Path("/weather/input/tq.txt"));
            // 输出路径
            Path outPath = new Path("/weather/output");
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

    > TQMapper  

    ```
    package com.hikvision.tq;
    import java.io.IOException;
    import java.text.ParseException;
    import java.text.SimpleDateFormat;
    import java.util.Calendar;
    import org.apache.hadoop.io.IntWritable;
    import org.apache.hadoop.io.LongWritable;
    import org.apache.hadoop.io.Text;
    import org.apache.hadoop.mapreduce.Mapper;
    import org.apache.hadoop.util.StringUtils;
    public class TQMapper extends Mapper<LongWritable, Text, Weather, IntWritable> {
        @Override
        protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            String[] strs = StringUtils.split(value.toString(), '\t');
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Calendar cal = Calendar.getInstance();
            try {
                cal.setTime(sdf.parse(strs[0]));
                Weather weather = new Weather();
                weather.setYear(cal.get(Calendar.YEAR));
                weather.setMonth(cal.get(Calendar.MONTH) + 1);
                weather.setDay(cal.get(Calendar.DAY_OF_MONTH));
                int temperature = Integer.parseInt(strs[1].substring(0, strs[1].lastIndexOf('c')));
                weather.setTemperature(temperature);
                context.write(weather, new IntWritable(temperature));
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
    }
    ```

    > TQPartition  

    ```
    package com.hikvision.tq;
    import org.apache.hadoop.io.IntWritable;
    import org.apache.hadoop.mapreduce.lib.partition.HashPartitioner;
    public class TQPartition extends HashPartitioner<Weather, IntWritable> {
        @Override
        public int getPartition(Weather key, IntWritable value, int numReduceTasks) {
            // 重写partition的过程，需要满足业务的规则
            // 越简单越好，会影响计算速度
            return (key.getYear() - 1949) % numReduceTasks;
            // return super.getPartition(key, value, numReduceTasks);
        }
    }
    ```

    > TQSort  

    ```
    package com.hikvision.tq;
    import org.apache.hadoop.io.WritableComparable;
    import org.apache.hadoop.io.WritableComparator;
    public class TQSort extends WritableComparator {
        // 重写构造方法
        public TQSort() {
            super(Weather.class, true);
        }
        @SuppressWarnings("rawtypes")
        @Override
        public int compare(WritableComparable a, WritableComparable b) {
            Weather w1 = (Weather) a;
            Weather w2 = (Weather) b;
            int c1 = Integer.compare(w1.getYear(), w2.getYear());
            if (c1 == 0) {
                int c2 = Integer.compare(w1.getMonth(), w2.getMonth());
                if (c2 == 0) {
                    return -Integer.compare(w1.getTemperature(), w2.getTemperature());
                }
                return c2;
            }
            return c1;
        }
    }
    ```
    > TQGroup  

    ```
    package com.hikvision.tq;
    import org.apache.hadoop.io.WritableComparable;
    import org.apache.hadoop.io.WritableComparator;
    public class TQGroup extends WritableComparator {
        public TQGroup() {
            super(Weather.class, true);
        }
        @SuppressWarnings("rawtypes")
        @Override
        public int compare(WritableComparable a, WritableComparable b) {
            Weather w1 = (Weather) a;
            Weather w2 = (Weather) b;
            int c1 = Integer.compare(w1.getYear(), w2.getYear());
            if (c1 == 0) {
                return Integer.compare(w1.getMonth(), w2.getMonth());
            }
            return c1;
        }
    }
    ```

    > TQReducer  

    ```
    package com.hikvision.tq;
    import java.io.IOException;
    import org.apache.hadoop.io.IntWritable;
    import org.apache.hadoop.io.NullWritable;
    import org.apache.hadoop.io.Text;
    import org.apache.hadoop.mapreduce.Reducer;
    public class TQReducer extends Reducer<Weather, IntWritable, Text, NullWritable> {
        @Override
        protected void reduce(Weather weather, Iterable<IntWritable> iterable, Context context) throws IOException, InterruptedException {
            int flag = 0;
            for (IntWritable i : iterable) {
                flag++;
                if (flag > 2) {
                    break;
                }
                String msg = weather.getYear() + "-" + weather.getMonth() + "-" + weather.getDay() + "-" + i.get();
                context.write(new Text(msg), NullWritable.get());
            }
        }
    }
    ```


## 提交job操作

- 新建文件夹，上传文件到hdfs
- 已经有了配置文件所以，使用方式2进行提交，需要手动打包，直接运行
    ```
    // 运行方式2：使用配置文件指定，屏蔽上面的手动指定,报错的需要指定跨平台，指定本地jar的位置
    conf.set("mapreduce.app-submission.cross-platform", "true");
    conf.set("mapred.jar", "D:\\mr\\tq.jar");
    ```

## 查看运行结果

- 控制台日志

    ```
    2018-05-02 15:22:31,473 WARN  mapreduce.JobResourceUploader (JobResourceUploader.java:uploadFiles(64)) - Hadoop command-line option parsing not performed. Implement the Tool interface and execute your application with ToolRunner to remedy this.
    2018-05-02 15:22:34,937 INFO  input.FileInputFormat (FileInputFormat.java:listStatus(283)) - Total input paths to process : 1
    2018-05-02 15:22:35,103 INFO  mapreduce.JobSubmitter (JobSubmitter.java:submitJobInternal(198)) - number of splits:1
    2018-05-02 15:22:35,119 INFO  Configuration.deprecation (Configuration.java:warnOnceIfDeprecated(1243)) - mapred.jar is deprecated. Instead, use mapreduce.job.jar
    2018-05-02 15:22:35,237 INFO  mapreduce.JobSubmitter (JobSubmitter.java:printTokens(287)) - Submitting tokens for job: job_1525168992297_0007
    2018-05-02 15:22:35,674 INFO  impl.YarnClientImpl (YarnClientImpl.java:submitApplication(273)) - Submitted application application_1525168992297_0007
    2018-05-02 15:22:35,825 INFO  mapreduce.Job (Job.java:submit(1294)) - The url to track the job: http://n3:8088/proxy/application_1525168992297_0007/
    2018-05-02 15:22:35,826 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1339)) - Running job: job_1525168992297_0007
    2018-05-02 15:22:48,438 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1360)) - Job job_1525168992297_0007 running in uber mode : false
    2018-05-02 15:22:48,439 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 0% reduce 0%
    2018-05-02 15:22:58,537 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 100% reduce 0%
    2018-05-02 15:23:14,820 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 100% reduce 33%
    2018-05-02 15:23:15,837 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1367)) -  map 100% reduce 100%
    2018-05-02 15:23:16,853 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1378)) - Job job_1525168992297_0007 completed successfully
    2018-05-02 15:23:17,092 INFO  mapreduce.Job (Job.java:monitorAndPrintJob(1385)) - Counters: 50
        File System Counters
            FILE: Number of bytes read=238
            FILE: Number of bytes written=501967
            FILE: Number of read operations=0
            FILE: Number of large read operations=0
            FILE: Number of write operations=0
            HDFS: Number of bytes read=347
            HDFS: Number of bytes written=101
            HDFS: Number of read operations=12
            HDFS: Number of large read operations=0
            HDFS: Number of write operations=6
        Job Counters 
            Killed reduce tasks=1
            Launched map tasks=1
            Launched reduce tasks=3
            Data-local map tasks=1
            Total time spent by all maps in occupied slots (ms)=7783
            Total time spent by all reduces in occupied slots (ms)=43298
            Total time spent by all map tasks (ms)=7783
            Total time spent by all reduce tasks (ms)=43298
            Total vcore-milliseconds taken by all map tasks=7783
            Total vcore-milliseconds taken by all reduce tasks=43298
            Total megabyte-milliseconds taken by all map tasks=7969792
            Total megabyte-milliseconds taken by all reduce tasks=44337152
        Map-Reduce Framework
            Map input records=10
            Map output records=10
            Map output bytes=200
            Map output materialized bytes=238
            Input split bytes=96
            Combine input records=0
            Combine output records=0
            Reduce input groups=5
            Reduce shuffle bytes=238
            Reduce input records=10
            Reduce output records=8
            Spilled Records=20
            Shuffled Maps =3
            Failed Shuffles=0
            Merged Map outputs=3
            GC time elapsed (ms)=498
            CPU time spent (ms)=8400
            Physical memory (bytes) snapshot=570830848
            Virtual memory (bytes) snapshot=7779991552
            Total committed heap usage (bytes)=175120384
        Shuffle Errors
            BAD_ID=0
            CONNECTION=0
            IO_ERROR=0
            WRONG_LENGTH=0
            WRONG_MAP=0
            WRONG_REDUCE=0
        File Input Format Counters 
            Bytes Read=251
        File Output Format Counters 
            Bytes Written=101
    job commit successfully...
    ```

- webUI和输出的目录
    > 输出目录下分为三个文件,和设定的三个reducer有关  
    ```
    1949-10-2-36
    1949-10-1-34
    #
    1950-1-1-32
    1950-10-2-41
    1950-10-1-37
    #
    1951-7-3-47
    1951-7-2-46
    1951-12-1-23
    ```
    > 查看webUI http://n3:8088/cluster 显示已经执行成功

