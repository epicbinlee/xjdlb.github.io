
---
title: 如何在next配置站内的搜索引擎？
date: 2018-04-03 15:13:52
tags: [列表,next,配置]
categories: 配置
toc: true
mathjax: true
---
本文介绍如何在next配置站内的搜索引擎。
<!-- more -->

## 配置过程
- 安装hexo-generator-searchdb插件，以管理员身份打开cmd进入项目目录下，运行
```
npm install hexo-generator-searchdb --save
```
- 在站点的-config.yml文件中增加
```
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```
- 配置theme/next/-config.yml文件
```
# Algolia Search
algolia_search:
  enable: false
  hits:
    per_page: 10
  labels:
    input_placeholder: Search for Posts
    hits_empty: "We didn't find any results for the search: ${query}"
    hits_stats: "${hits} results found in ${time} ms"
#
# Local search
# Dependencies: https://github.com/flashlab/hexo-generator-search
local_search:
  enable: true
  # if auto, trigger search by changing input
  # if manual, trigger search by pressing enter key or search button
  trigger: auto
  # show top n results per article, show all results by setting to -1
  top_n_per_article: 1
```
