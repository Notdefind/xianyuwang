#!/bin/bash

echo "##### "
echo "##### 同步中"
echo "#####"

WWW_DIR="public/"
TARGET_DIR="/data/wwwroot/blog.notdefind.com/"

rsync -avz -e 'ssh' $WWW_DIR root@39.106.54.76:$TARGET_DIR