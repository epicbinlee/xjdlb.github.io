
---
title: eclipse中的git基本配置
date: 2018-04-16 18:56:26
tags: [列表,配置,git,eclipse]
categories: 配置
toc: true
mathjax: true
---
本文介绍了如何使用git和eclipse进行代码的版本控制。
<!-- more -->

## 命令行模式操作
- 服务端注册github或者giteee账号
- 客户端下载git软件
- 使用命令生成本地的密钥
- 将秘钥添加到服务端的git中
- 服务端新建git仓库，客户端克隆到本地
- 客户端添加文件到仓库中，使用各种命令对该仓库进行版本控制
- 上述的属于git的基本操作详细步骤参考 [如何利用ubuntu实现私有git服务端-附ssh操作？]( https://leebin.top/2018/03/27/%E5%A6%82%E4%BD%95%E5%88%A9%E7%94%A8ubuntu%E5%AE%9E%E7%8E%B0%E7%A7%81%E6%9C%89git%E6%9C%8D%E5%8A%A1%E7%AB%AF-%E9%99%84ssh%E6%93%8D%E4%BD%9C%EF%BC%9F/)

## eclipse中git上传代码
- 服务端已经添加了客户端的ssh密钥
- 服务端已经新建了仓库
- 客户端eclipse新建项目
- 在路径eclipse>windows>preference>team>git>configuration下查看user和passwd的配置
- 在路径package explorer>项目右键>share project>repository>create，新建本地的仓库名字要和服务端的名字一致，如：d:\\test.git，完成了新建仓库
- 在路径package explorer>项目右键>team>add to index，完成文件的add
- 在路径package explorer>项目右键>team>commit或者Ctrl+#，提交
- 接上一步，先填写commit message
- 接上一步，填写服务器地址
```
remote name: origin
url: git@github.com:xjdlb/testgit.git # git 地址
hostname: github.com # 域名
repository path: xjdlb/testgit.git
```
- 一路next就好了
- [他山之石](https://blog.csdn.net/u014079773/article/details/51595127)

## eclipse中git下载代码
- 在路径package explorer>空白右键>import>Git>Projects from Git，next
- 接上步，选择URI，包含了远程和本地
- 主要的分支
- 新建本地的仓库，如：d:\\test.git
- 继续coding
- 返回上面上传代码操作

## eclipse push 出现了 rejected-non-fast-forward错误
- [他山之石](https://blog.csdn.net/chenshun123/article/details/46756087)
- 打开windows>show view>other>git repositories
- git repositories>remote>origin>绿色分支>右键>configure fetch>save and fetch
- 此时可以看见remote tracking>origin/mater>右键>merge
- 问题解决，可以上传了
- add>commit>push
