#!/bin/bash

count=0
tempfile=$(mktemp)

squeue -p Ai4sci_3D | grep 'gpu:1' > "$tempfile"

while read -r line; do
    echo "$line"
    # 从行中提取任务ID
    job_id=$(echo "$line" | awk '{print $1}')
    # 增加计数器
    count=$((count + 1))
done < "$tempfile"

echo "Total lines: $count"

# 删除临时文件
rm "$tempfile"
