#!/bin/bash

git pull

# 在部署前先清理旧文件
hexo clean
# 在部署前先生成
hexo d -g
git add .
git commit -m "change blog"
git push


