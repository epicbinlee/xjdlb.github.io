
---
title: LC_001_TwoSum_HashMap
date: 2018-04-03 22:42:05
tags: [列表,leetcode,java,basic algorithm]
categories: leetcode
toc: true
mathjax: true
---
leetcode第001题，主要用到了hashmap数据结构。
<!-- more -->
## 题解
```java
package LC;

import java.util.Arrays;
import java.util.HashMap;

/**
 * https://leetcode.com/problems/two-sum/description/
 * Given an array of integers,
 * return indices of the two numbers such that they add up to a specific target.
 * You may assume that each input would have exactly one solution,
 * and you may not use the same element twice.
 * Example:
 * Given nums = [2, 7, 11, 15], target = 9,
 * Because nums[0] + nums[1] = 2 + 7 = 9,
 * return [0, 1].
 */

public class LC_001_TwoSum_HashMap {
    public static void main(String[] args) {
        int[] a = {1, 2, 3, 4, 5, 7};
        int t = 10;
        System.out.println(Arrays.toString(twoSum(a, t)));
    }

    private static int[] twoSum(int[] nums, int target) {
        HashMap<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int diff = target - nums[i];
            if (map.containsKey(diff)) return new int[]{map.get(diff), i};
            map.put(nums[i], i);
        }
        throw new IllegalArgumentException("-1");
    }
}

```
