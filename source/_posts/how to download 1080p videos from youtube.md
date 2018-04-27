
---
title: how to download 1080p videos from youtube
date: 2018-04-23 20:36:16
tags: [列表,vps,youtube]
categories: configuration
toc: true
mathjax: true
---

the article describes how to download 1080p videos form youtube with your foreigen vps/ecs.

<!-- more -->

## general method
- chrome browser
- copy the link of the video from youtube
- paste the link to the input box of https://en.savefrom.net/
- download videos though chrome

## advance method
- login in your foreign vps
- such as: ubuntu from digitalocean
- use the following cmd to download the video
```
apt-get install youtube-dl -y
youtube-dl -f 22 your_video_link
```

## ultimate method
- use the following cmd to analysis all videos and audios about your_video_link
```
youtube-dl -F your_video_link
```

- use the following cmd to download videos and audios with the specified code
```
youtube-dl -f 10 your_video_link
```

- install the tools of video and audio
```
apt-get install ffmpeg -y
```

- merge the video and audio
```
ffmpeg -i /tmp/a.wav -i /tmp/a.avi /tmp/out.avi
```

## how to download playlist from youtube
- cmd
```
youtube-dl -citk –format mp4 –yes-playlist VIDEO_PLAYLIST_LINK
youtube-dl -citk –format mp4 –yes-playlist https://www.youtube.com/playlist?list=PLi8jnEH_cKdzioH63X5NLJjHGJcYZcfua
youtube-dl -cit "https://www.youtube.com/playlist?list=PLi8jnEH_cKdzioH63X5NLJjHGJcYZcfua"
```
