---
title: 使用github pages和hexo搭建自己的博客
date: 2018-03-27 12:00:00
tags: [列表,github,pages,hexo]
categories: 配置
toc: true
mathjax: true
---

本文描述了如何使用github pages和hexo搭建自己的博客。
<!-- more -->

## 安装node.js
- [node.js下载地址](https://nodejs.org/en/)
- 下载node.js，并安装

## 安装git并配置ssh密钥
- 在客户端下载[git下载地址](https://git-scm.com/downloads/)
- 安装git
- 在客户端右键打开git bash here
- 设置user.name和user.email
```
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub注册邮箱"
```
- 生成ssh密钥
```
ssh-keygen -t rsa -C "你的GitHub注册邮箱"
```
- 显示密钥
```
cat ~/.ssh/id_rsa.pub
```
- 添加密钥到github服务器中密钥管理[添加地址](https://github.com/settings/keys)

## 安装hexo
- 安装hexo、安装扩展插件
```
# 安装hexo
npm install hexo-cli g
# 初始化博客文件夹
hexo init blog
# 切换到该路径
cd blog
# 安装hexo的扩展插件
npm install
# 安装其它插件
npm install hexo-server --save
npm install hexo-admin --save
npm install hexo-generator-archive --save
npm install hexo-generator-feed --save
npm install hexo-generator-search --save
npm install hexo-generator-tag --save
npm install hexo-deployer-git --save
npm install hexo-generator-sitemap --save
```

## 本地开发blog与本地测试
- 添加自己的markdown到 blog/source/posts目录下
- 生成静态页面并开启服务器
```
# 生成静态页面
hexo generate
# 开启本地服务器
hexo s
# 或者
hexo s -p 指定的port
```
- 打开浏览器，地址栏中输入：http://localhost:4000/

## 服务端新建自己的博客仓库
- 在 https://github.com/new 中新建自己的仓库
- 其中Repository name要和Owner是一致的

## 客户端将hexo博客部署到github上
- 修改配置文件blog/config.yml，修改deploy项的内容
```
# Deployment 注释
## Docs: https://hexo.io/docs/deployment.html
deploy:
  # 类型
  type: git
  # 仓库
  repo: git@github.com:xjdlb/xjdlb.github.io.git
  # 分支
  branch: master
```
- 注意：type: git中的冒号后面由空格
- 注意：将xjdlb换成自己的用户名

## 客户端将自己的blog部署hexo
- 将自己的项目部署到github pages中
```
# 清空静态页面
hexo clean
# 生成静态页面
hexo generate
# 部署
hexo deploy
```
- 打开网页，输入 http://github_username.github.io 打开github上托管的博客
- 如我的博客地址是：http://xjdlb.github.io

## hexo命令缩写与组合
- 含义
```
hexo g：hexo generate
hexo c：hexo clean
hexo s：hexo server
hexo d：hexo deploy
```
- 组合
```
# 清除、生成、启动
hexo clean && hexo g -s
# 清除、生成、部署
hexo clean && hexo g -d
```

## 主题相关配置
- 在[hexo themes](https://hexo.io/themes/)中下载相关的主题
- 下载方法在blog目录中克隆
```
git clone https://github.com/iissnan/hexo-theme-next themes/next
```
- 在blog/config.yml中配置主题
```
theme: next
```

## 新建blog文件
- hexo new "Hexo教程"
- 添加标题及其分类信息
```
title: Hello World
date: 2016-01-15 20:19:32
tags: [SayHi]
categories: SayHi
toc: true
mathjax: true
```
- 或者 在blog目录下可以写成脚本
```
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
echo "tags: [2222,3333,4444]" >> $filename$filepostfix
echo "categories: 5555" >> $filename$filepostfix
echo "toc: true" >> $filename$filepostfix
echo "mathjax: true" >> $filename$filepostfix
echo "---" >> $filename$filepostfix
cd ../..
```

## 将github pages绑定自己的域名
- 在阿里云控制台找到域名管理
- 在阿里云上购买自己的域名[注册地址](https://help.aliyun.com/product/35473.html)
- 在xjdlb/xjdlb.github.io/settings中Custom domain处添加自己的域名，不要http://和www
- ping https://xjdlb.github.io/ 查看github pages的ip
- 添加解析

记录类型|主机记录|解析线路|记录值|TTL值
--|--|--|--|--
A|@|默认|151.101.41.147|600
A|www|默认|151.101.41.147|600

- 使用自己的域名测试

## CNAME问题
问题：每次hexo deploy之后，https://www.leebin.top 都会出现404错误
一般解决：Github pages–>Settings–>Custom domain
最优解决：在将CNAME文件放在source目录下，CNAME文件内容为：leebin.top

## 环境变更
- 换电脑，安装环境
```
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub注册邮箱"
node -v
npm -v
git --version
npm intsall hexo -g 或 npm install hexo-cli g
hexo -v
npm install
npm install hexo-deployer-git --save
# 下面是全部组件，源git仓库不需要全部用上
npm install hexo-server --save
npm install hexo-admin --save
npm install hexo-generator-archive --save
npm install hexo-generator-feed --save
npm install hexo-generator-search --save
npm install hexo-generator-tag --save
npm install hexo-deployer-git --save
npm install hexo-generator-sitemap --save
```