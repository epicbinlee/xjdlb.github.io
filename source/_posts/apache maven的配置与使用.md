
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



