
---
title: apache maven的配置与使用
date: 2018-04-17 11:49:36
tags: [列表,配置,windows,maven]
categories: 配置
toc: true
mathjax: true
---

本文介绍了apache maven的配置与使用过程。

<!-- more -->

## 需要先配置java和maven环境变量

- CLASSPATH
```
.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar;
```

- JAVA_HOME
```
C:\app3\Java\jdk1.8.0_144
```

- JRE_HOME
```
C:\app3\Java\jre1.8.0_144
```

- MVN_HOME
C:\app3\apache-maven-3.5.3

- Path
```
C:\app3\Python35\Scripts\;C:\app3\Python35\;C:\ProgramData\Oracle\Java\javapath;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;%JAVA_HOME%\bin;%JRE_HOME%\bin;C:\app3\Git\cmd;C:\app3\MinGW\bin;C:\app3\nodejs\;C:\app3\MATLAB\R2017b\runtime\win64;C:\app3\MATLAB\R2017b\bin;%MVN_HOME%\bin;
```

## 更换maven的仓库为自定义的仓库
- 创建目标位置如，d:\maven\repo
- 拷贝C:\app3\apache-maven-3.5.3\conf\settings.xml文件到d:\maven
- 修改两处的settings.xml文件
- 定位到localRepository
```
<localRepository>/path/to/local/repo</localRepository>
# 修改为：
<localRepository>d:\maven\repo</localRepository>
```

## maven手动创建项目
- [他山之石](https://www.cnblogs.com/yjmyzz/p/3495762.html)

- 创建项目
```
# cmd
cd /d d:\test
mvn archetype:generate
# log
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): 1169:（和eclipse上的maven插件有关系，直接回车）
Choose org.apache.maven.archetypes:maven-archetype-quickstart version:
1: 1.0-alpha-1
2: 1.0-alpha-2
3: 1.0-alpha-3
4: 1.0-alpha-4
5: 1.0
6: 1.1
7: 1.3
Choose a number: 7:(直接回车)
Define value for property 'groupId': com.hikvision.ai_data.data（从大往小填写自己公司的名字）
Define value for property 'artifactId': test_mvn（项目的名字）
Define value for property 'version' 1.0-SNAPSHOT: :（默认就行）
Define value for property 'package' com.hikvision.ai_data.data: : test_mvn_pkg（将class打包的jar文件的名称）
Confirm properties configuration:
groupId: com.hikvision.ai_data.data
artifactId: test_mvn
version: 1.0-SNAPSHOT
package: test_mvn_pkg
 Y: :(直接回车)
[INFO] ----------------------------------------------------------------------------
[INFO] Using following parameters for creating project from Archetype: maven-archetype-quickstart:1.3
[INFO] ----------------------------------------------------------------------------
[INFO] Parameter: groupId, Value: com.hikvision.ai_data.data
[INFO] Parameter: artifactId, Value: test_mvn
[INFO] Parameter: version, Value: 1.0-SNAPSHOT
[INFO] Parameter: package, Value: test_mvn_pkg
[INFO] Parameter: packageInPathFormat, Value: test_mvn_pkg
[INFO] Parameter: package, Value: test_mvn_pkg
[INFO] Parameter: version, Value: 1.0-SNAPSHOT
[INFO] Parameter: groupId, Value: com.hikvision.ai_data.data
[INFO] Parameter: artifactId, Value: test_mvn
[INFO] Project created from Archetype in dir: D:\003---WorkSpace\06---testmaven\test_mvn
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 13:57 min
[INFO] Finished at: 2018-04-17T14:54:37+08:00
[INFO] ------------------------------------------------------------------------
[0m[0m
```

- 创建项目后查看文件
```
D:\003---WorkSpace\06---testmaven>tree
卷 工厂 的文件夹 PATH 列表
卷序列号为 0000006C BAA7:827C
D:.
└─test_mvn
    └─src
        ├─main
        │  └─java
        │      └─test_mvn_pkg
        └─test
            └─java
                └─test_mvn_pkg
```

- 编译项目
```
# cmd
cd test_mvn
mvn clean compile
# log
D:\003---WorkSpace\06---testmaven\test_mvn>mvn clean compile
[INFO] Scanning for projects...
[INFO]
[INFO] ----------------< com.hikvision.ai_data.data:test_mvn >-----------------
[INFO] Building test_mvn 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-clean-plugin:3.0.0:clean (default-clean) @ test_mvn ---
[INFO]
[INFO] --- maven-resources-plugin:3.0.2:resources (default-resources) @ test_mvn ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\003---WorkSpace\06---testmaven\test_mvn\src\main\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:compile (default-compile) @ test_mvn ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to D:\003---WorkSpace\06---testmaven\test_mvn\target\classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.570 s
[INFO] Finished at: 2018-04-17T14:58:59+08:00
[INFO] ------------------------------------------------------------------------
```

- 单元测试
```
# cmd
mvn clean test
# log
D:\003---WorkSpace\06---testmaven\test_mvn>mvn clean test
[INFO] Scanning for projects...
[INFO]
[INFO] ----------------< com.hikvision.ai_data.data:test_mvn >-----------------
[INFO] Building test_mvn 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-clean-plugin:3.0.0:clean (default-clean) @ test_mvn ---
[INFO] Deleting D:\003---WorkSpace\06---testmaven\test_mvn\target
[INFO]
[INFO] --- maven-resources-plugin:3.0.2:resources (default-resources) @ test_mvn ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\003---WorkSpace\06---testmaven\test_mvn\src\main\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:compile (default-compile) @ test_mvn ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to D:\003---WorkSpace\06---testmaven\test_mvn\target\classes
[INFO]
[INFO] --- maven-resources-plugin:3.0.2:testResources (default-testResources) @ test_mvn ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\003---WorkSpace\06---testmaven\test_mvn\src\test\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:testCompile (default-testCompile) @ test_mvn ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to D:\003---WorkSpace\06---testmaven\test_mvn\target\test-classes
[INFO]
[INFO] --- maven-surefire-plugin:2.20.1:test (default-test) @ test_mvn ---
[INFO]
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running test_mvn_pkg.AppTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.057 s - in test_mvn_pkg.AppTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.227 s
[INFO] Finished at: 2018-04-17T15:00:33+08:00
[INFO] ------------------------------------------------------------------------
```

- 打包项目
```
# cmd
mvn clean package
# log
D:\003---WorkSpace\06---testmaven\test_mvn>mvn clean package
[INFO] Scanning for projects...
[INFO]
[INFO] ----------------< com.hikvision.ai_data.data:test_mvn >-----------------
[INFO] Building test_mvn 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-clean-plugin:3.0.0:clean (default-clean) @ test_mvn ---
[INFO] Deleting D:\003---WorkSpace\06---testmaven\test_mvn\target
[INFO]
[INFO] --- maven-resources-plugin:3.0.2:resources (default-resources) @ test_mvn ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\003---WorkSpace\06---testmaven\test_mvn\src\main\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:compile (default-compile) @ test_mvn ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to D:\003---WorkSpace\06---testmaven\test_mvn\target\classes
[INFO]
[INFO] --- maven-resources-plugin:3.0.2:testResources (default-testResources) @ test_mvn ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\003---WorkSpace\06---testmaven\test_mvn\src\test\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.7.0:testCompile (default-testCompile) @ test_mvn ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to D:\003---WorkSpace\06---testmaven\test_mvn\target\test-classes
[INFO]
[INFO] --- maven-surefire-plugin:2.20.1:test (default-test) @ test_mvn ---
[INFO]
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running test_mvn_pkg.AppTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.052 s - in test_mvn_pkg.AppTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO]
[INFO] --- maven-jar-plugin:3.0.2:jar (default-jar) @ test_mvn ---
[INFO] Building jar: D:\003---WorkSpace\06---testmaven\test_mvn\target\test_mvn-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.599 s
[INFO] Finished at: 2018-04-17T15:02:35+08:00
[INFO] ------------------------------------------------------------------------
```

- 运行项目
```
# cmd
# 1.无参数，类在target下面test_mvn\target\classes\test_mvn_pkg\App.class
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main"
# 即
mvn exec:java -Dexec.mainClass="test_mvn_pkg.App"
#
# 2.有参数
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.args="arg0 arg1 arg2"
#
# 3.指定对classpath的运行时依赖
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.classpathScope=runtime
#
# log
D:\003---WorkSpace\06---testmaven\test_mvn>mvn exec:java -Dexec.mainClass="test_mvn_pkg.App"
[INFO] Scanning for projects...
[INFO]
[INFO] ----------------< com.hikvision.ai_data.data:test_mvn >-----------------
[INFO] Building test_mvn 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- exec-maven-plugin:1.6.0:java (default-cli) @ test_mvn ---
Hello World!
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.010 s
[INFO] Finished at: 2018-04-17T15:09:49+08:00
[INFO] ------------------------------------------------------------------------
```

- 项目部署
```
# 前提是jboss web server已经成功启动
# cmd
mvn clean jboss-as:deploy
```