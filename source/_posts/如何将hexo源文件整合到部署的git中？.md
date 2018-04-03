
---
title: 如何将hexo源文件整合到部署的git中？
date: 2018-03-28 14:46:11
tags: [列表,hexo,配置,git]
categories: 配置
toc: true
mathjax: true
---

本文介绍如何将hexo源文件整合到部署的git中，实现不携带源文件也能写博客，其中，发布和部署实现了自动化脚本操作。

<!-- more -->

## 先决条件
- 已经使用了hexo部署了自己的blog
- 源文件没有丢失

## 克隆
- 在github上克隆部署后的文件到本地客户端
- 使用git bash here进入git仓库
- 新建hexo分支并转换到hexo分支
```bash
git checkout -b hexo
```

## 拷贝
- git仓库转换到hexo分支
- 将源文件blog文件夹下的所有文件拷贝到上述git仓库中

## 创建自动化脚本
- 在git仓库的根目录下创建脚本
- 脚本1 create_new_page.sh
```bash
echo "hello"
yy=$(date +%Y)
mm=$(date +%m)
dd=$(date +%d)
HH=$(date +%H)
MM=$(date +%M)
SS=$(date +%S)
filename="11111"
filepostfix=".md"
cd source/_posts
touch $filename$filepostfix
echo > $filename$filepostfix
echo "---" >> $filename$filepostfix
echo "title: $filename" >> $filename$filepostfix
echo "date: $yy-$mm-$dd $HH:$MM:$SS" >> $filename$filepostfix
echo "tags: [列表,2222,3333,4444]" >> $filename$filepostfix
echo "categories: 5555" >> $filename$filepostfix
echo "toc: true" >> $filename$filepostfix
echo "mathjax: true" >> $filename$filepostfix
echo "---" >> $filename$filepostfix
echo "" >> $filename$filepostfix
echo "<!-- more -->" >> $filename$filepostfix
cd ../..
```
- 文本1 commit.txt
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
$yy/$mm/$dd-$HH:$MM:$SS 新增了列表标签
"
git push origin hexo
git  log --oneline | head
echo "=================================="
hexo clean && hexo g -d
```
- 脚本2 upload_and_deploy.sh
```bash
ehco "push and deploy..."
sh commit.txt
```
- 本次修改完成直接在commit.txt中修改commit，然后运行upload_and_deploy.sh，即可上传代码到hexo分支，发布blog到master分支

## 换个地点继续写作
- 先决条件：电脑+网络+nodejs+hexo
- 克隆仓库到本地
- 在仓库中建立hexo配置脚本 init_hexo_after_clone.sh
```
git checkout hexo
npm install hexo
npm install
npm install hexo-deployer-git
```
