
---
title: 如何去掉valine的Powered By信息？
date: 2018-04-03 22:42:05
tags: [列表,valine,配置]
categories: 配置
toc: true
mathjax: true
---

本文介绍如何去掉valine页面上的Powered By信息。
<!-- more -->

## 步骤
- 找到配置文件
```
blog/themes/next/layout/_third-party/comments/valine.swig
```
- 配置如下
```
{% if theme.valine.enable and theme.valine.appid and theme.valine.appkey %}
  <script src="//cdn1.lncld.net/static/js/3.0.4/av-min.js"></script>
  <script src="//unpkg.com/valine/dist/Valine.min.js"></script>
  <script type="text/javascript">
    var GUEST = ['nick','mail','link'];
    var guest = '{{ theme.valine.guest_info }}';
    guest = guest.split(',').filter(item=>{
      return GUEST.indexOf(item)>-1;
    });
    new Valine({
        el: '#comments' ,
        verify: {{ theme.valine.verify }},
        notify: {{ theme.valine.notify }},
        appId: '{{ theme.valine.appid }}',
        appKey: '{{ theme.valine.appkey }}',
        placeholder: '{{ theme.valine.placeholder }}',
        avatar:'{{ theme.valine.avatar }}',
        guest_info:guest,
        pageSize:'{{ theme.valine.pageSize }}' || 10,
    });
	//新增以下代码即可，可以移除.info下所有子节点。
	var infoEle = document.querySelector('#comments .info');
	if (infoEle && infoEle.childNodes && infoEle.childNodes.length > 0){
	  infoEle.childNodes.forEach(function(item) {
		item.parentNode.removeChild(item);
	  });
	}
  </script>
{% endif %}
```
