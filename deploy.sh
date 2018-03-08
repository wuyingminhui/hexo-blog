#!/bin/bash

git pull

./delete_all_post_folders.sh

# 在部署前先清理旧文件
hexo clean
# 在部署前先生成
hexo d -g
git add  -A .
git commit -m "change blog"
git push


