#!/bin/bash

# 外部输入的hugo public目录路径
hugo_public_dir="$1"

# 校验hugo public目录路径是否存在
if [ ! -d "$hugo_public_dir" ]; then
  echo "错误：hugo public目录路径不存在！"
  exit 1
fi

# 当前脚本所在的目录路径
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$script_dir"
rm -rf 404.html about categories css en images index.* js lib page posts sitemap.xml sponsor svg tags zh-cn/
cp -ra $hugo_public_dir/* $script_dir/

# 检查rsync操作结果
if [ $? -eq 0 ]; then
  echo "同步操作成功"
  
  # 提交GitHub Pages的git repo
  cd "$script_dir"
  git add .
  commit_message="commit by $(whoami) at $(date +"%Y-%m-%d %H:%M:%S")"
  git commit -m "$commit_message"
  git push origin main
  
  echo "提交成功: $commit_message"
else
  echo "错误：同步操作失败"
fi

