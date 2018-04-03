
---
title: hexo如何开启语法高亮？
date: 2018-04-03 22:42:05
tags: [列表,配置,hexo]
categories: 配置
toc: true
mathjax: true
---
本文介绍hexo有关语法高亮的配置方案。
<!-- more -->

## 配置过程

- 配置主站点下的配置文件
```
highlight:
  enable: true
  line_number: true
  auto_detect: true
  tab_replace:
```
- 代码后面添加名称，如\`\`\`java code \`\`\`

