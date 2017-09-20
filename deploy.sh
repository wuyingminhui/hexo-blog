#!/bin/bash

# 在部署前先清理旧文件
hexo clean
# 在部署前先生成
hexo d -g
git add .
git commit
git push
