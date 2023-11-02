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

# 忽略列表文件路径
ignore_list_file="$script_dir/rsync_ignore.txt"

# 更新忽略列表文件
touch "$ignore_list_file"
echo "$(basename $0)" > "$ignore_list_file"
echo "rsync_ignore.txt" >> "$ignore_list_file"
echo ".git" >> "$ignore_list_file"
echo "CNAME" >> "$ignore_list_file"
ls -l "$script_dir"

# 同步public目录到GitHub Pages的git repo
rsync -a --exclude-from="$ignore_list_file" "$hugo_public_dir/" "$script_dir/"
rsync_status=$?

# 删除忽略列表文件
rm "$ignore_list_file"

# 检查rsync操作结果
if [ $rsync_status -eq 0 ]; then
  echo "rsync操作成功"
  
  # 提交GitHub Pages的git repo
  cd "$script_dir"
  git add .
  commit_message="commit by $(whoami) at $(date +"%Y-%m-%d %H:%M:%S")"
  git commit -m "$commit_message"
  git push origin main
  
  echo "提交成功: $commit_message"
else
  echo "错误：rsync操作失败"
fi

