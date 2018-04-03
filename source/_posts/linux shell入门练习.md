
---
title: linux shell入门练习
date: 2018-04-03 09:45:24
tags: [列表,shell,linux]
categories: shell
toc: true
mathjax: true
---
本文介绍linux shell的入门程序，后期会陆续更新。
<!-- more -->
## 基本程序实例
- 计算文件夹下的文件数量
```bash
#!/bin/bash
echo "this is a shell print file's number in the local dir."
ls > filename.log
y=1
for i in $( cat filename.log )
	do
		echo "the file number is $y"
		y=$(( $y + 1 ))
	done
rm -rf filename.log
```

- 简单求和程序
```bash
#!/bin/bash
# author: leebin
s=0
for(( i=1; i<=100; i=i+1 ))
	do
		s=$(( $s+$i ))
	done
echo "the sum of 1+2+3+...+100 is $s"
```

- 使用数组
```bash
#!/bin/bash
for x in morning noon afternoon evening
	do
		echo "This time is $x"
	done
```

- 使用函数
```bash
#!/bin/bash
function func1(){
	echo AAA
}
func1
echo this is the end of the loop
echo Now this is the end of the script
```

- 判断
```bash
#!/bin/bash
if [ -d /etc/mysql ]
	then
		echo "the path is right!!"
	else
		echo "the path is not right"
fi
```

- 判断硬盘是否已经满了
```bash
#!/bin/bash
# Author: LeeBin
rate=$( df | grep "sda" | awk '{print $5}'| cut -d "%" -f 1 )
if [ $rate -ge 80 ]
	then
		echo "Warning! /dev/sda1 is full!!"
	else
		echo "/dev/sda1 is not full!!"
fi
```

- until循环
```bash
#!/bin/bash
# Author:LeeBin
i=1
s=0
until [ $i -gt 100 ]
	do
		s=$(( $s+$i ))
		i=$(( $i+1 ))
	done
echo "the sum is $s"
```

- while循环
```bash
#!/bin/bash
function func1(){
      echo this is an example of a function
}
count=1
while [ $count -le 5 ]
do
    func1
    count=$[ $count+1 ]
done
echo end of loop
func1
echo end of script
```

- while循环求和
```bash
#!/bin/bash
# Author:LeeBin
i=1
s=0
#
while [ $i -le 100 ]
	do
		s=$(( $s+$i ))
		i=$(( $i+1 ))
	done
echo "the sum is $s"
```

- 备份脚本
```bash
#!/bin/sh
# auto mail for system info
# time
/bin/date +%F >> ~/app/shell/sysinfo
echo >> ~/app/shell/sysinfo
# disk info
echo "disk info:" >> ~/app/shell/sysinfo
/bin/df -h >> ~/app/shell/sysinfo
echo >> ~/app/shell/sysinfo
echo "online users" >> ~/app/shell/sysinfo
/usr/bin/who | /bin/grep -v root >> ~/app/shell/sysinfo
echo >> ~/app/shell/sysinfo
echo "memory info:" >> ~/app/shell/sysinfo
/usr/bin/free -m >> ~/app/shell/sysinfo
echo >> ~/app/shell/sysinfo
```

- case语句
```bash
#!/bin/bash
# author: leebin
read -p "Please choose yes/no: " -t 30 cho
#
case $cho in
	"yes")
		echo "Your choose is yes!!"
		;;
	"no")
		echo "Your choose is no!!"
		;;
	*)
		echo "Your choose is error!!"
		;;
esac
#
```

- 批量解压缩
```bash
#!/bin/bash
# author: leebin
cd /lamp
ls *.tar.gz > ls.log
#
for i in $( cat ls.log )
	do
		tar -zxvf $i &> /dev/null
	done
#
rm -rf /lamp/ls.log
```
