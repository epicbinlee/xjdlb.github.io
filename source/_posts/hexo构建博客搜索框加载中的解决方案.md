
---
title: hexo构建博客搜索框加载中的解决方案
date: 2018-04-19 14:37:10
tags: [列表,hexo]
categories: 配置
toc: true
mathjax: true
---

本文介绍nodejs+hexo+github+markdown搭建博客后，点击搜素框，一直在加载中的解决方案。

<!-- more -->

## 问题与现象
- nodejs+hexo+github+markdown搭建博客后，点击搜素框，一直在加载中的解决方案。

## 原因
- 开发的markdown中出现了非utf-8的字符。
- 访问可以查找错误出现的位置：https://leebin.top/search.xml

## 解决方案
- 逐个排查每个markdown文件，直到找到非utf-8字符，删除，重新部署，点击搜索框测试。
- 访问：https://leebin.top/search.xml 发现可以解析成源文件。
