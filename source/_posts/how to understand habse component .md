
---
title: how to understand habse component ?
date: 2018-04-24 16:45:26
tags: [列表,hbase,configuration]
categories: configuration
toc: true
mathjax: true
---

This article describes the basic components of hbase, including HMaster, HRegionServer, Region.

<!-- more -->

## principle of hbase

- **features of HMaster (Technical Director)**
1. Add, delete, and modify tables
2. Load balancing the region
3. HMaster manages the distribution of all data

- **features of RegionServer (department manager)**
1. RegionServer is the service component of Hbase
2. RegionServer maintains Regions assigned by HMaster
3. RegionServer can divide big Regions

- **features of Region (developers)**
1. Region is a partition
2. handling the tasks assigned by RegionServer
