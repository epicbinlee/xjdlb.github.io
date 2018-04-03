
---
title: git pages的迁移和多服务器部署
date: 2018-03-29 09:34:52
tags: [列表,git,配置]
categories: 配置
toc: true
mathjax: true
---

本文介绍如何将github上的项目迁移到gitee上，如何实现源文件多服务器的部署。
<!-- more -->

## github pages迁移到gitee服务器上
- 在gitee上新建一个和gitee用户名一样的git仓库，并且在pages标签开启pages服务
- 克隆github pages仓库到本地，安装必要的插件，保证github pages能够与github服务器正常上传部署
- 更改github仓库/.git/config文件
```
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = git@github.com:xjdlb/xjdlb.github.io.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```
- 更改url为gitee仓库的url
- 更改github仓库/-config.yml文件
```
deploy:
  type: git
  repo:
        gitee: git@gitee.com:bin_lee/bin_lee.git
  branch: master
```
- 更改repo为gitee仓库的url
- 然后使用下面的脚本提交、推送、发布到gitee仓库，迁移就成功了
```bash
echo "hello"
yy=$(date +%y)
mm=$(date +%m)
dd=$(date +%d)
HH=$(date +%H)
MM=$(date +%M)
SS=$(date +%S)
xW=$(date +%U)
we=$(date +%a)
xD=$(date +%j)
git status
git add .
git commit -m "
$yy/$mm/$dd-$HH:$MM:$SS 把github服务器上的pages迁移到gitee上
"
echo "=================================="
git push git@gitee.com:bin_lee/bin_lee.git hexo
git  log --oneline | head
echo "=================================="
hexo clean && hexo g -d
```

## 迁移完成，实现多服务器部署
- 更改github仓库/.git/config文件，改为主要的服务器地址
```
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = git@github.com:xjdlb/xjdlb.github.io.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```
- 更改url为gitee仓库的url
- 更改github仓库/-config.yml文件
```
deploy:
  type: git
  repo:
        github: git@github.com:xjdlb/xjdlb.github.io.git
        gitee: git@gitee.com:bin_lee/bin_lee.git
  branch: master
```
- 更改repo为gitee仓库的url
- 然后使用下面的脚本提交、推送、发布到gitee仓库和github仓库，多服务器部署就成功了
```bash
echo "hello"
yy=$(date +%y)
mm=$(date +%m)
dd=$(date +%d)
HH=$(date +%H)
MM=$(date +%M)
SS=$(date +%S)
xW=$(date +%U)
we=$(date +%a)
xD=$(date +%j)
git status
git add .
git commit -m "
$yy/$mm/$dd-$HH:$MM:$SS 同时部署到两个服务器上测试
"
git push git@github.com:xjdlb/xjdlb.github.io.git hexo
git  log --oneline | head
echo "=================================="
git push git@gitee.com:bin_lee/bin_lee.git hexo
git  log --oneline | head
echo "=================================="
hexo clean && hexo g -d
```
