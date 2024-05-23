#!/bin/bash

# 默认GPU数量为1
gpu_num=1
exclude_users=()
exclude_jobs=()
exclude_spot=0  # 默认不排除spot类型的任务
cancel_jobs=0  # 默认不执行取消操作

# 解析命令行参数
while getopts "n:u:j:sc" opt; do
  case $opt in
    n) gpu_num=$OPTARG ;;
    u) exclude_users+=($OPTARG) ;;
    j) exclude_jobs+=($OPTARG) ;;
    s) exclude_spot=1 ;;
    c) cancel_jobs=1 ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

count=0
tempfile=$(mktemp)

# 根据输入的GPU数量过滤任务
squeue -p Ai4sci_3D | grep "gpu:$gpu_num" > "$tempfile"

while read -r line; do
  # 检查行是否包含任何排除的用户、任务ID或spot类型
  skip=0
  job_id=$(echo "$line" | awk '{print $1}')
  job_type=$(echo "$line" | awk '{print $4}')  # 假设类型在第4列

  for user in "${exclude_users[@]}"; do
    if echo "$line" | grep -q "$user"; then
      skip=1
      break
    fi
  done

  for id in "${exclude_jobs[@]}"; do
    if [ "$job_id" == "$id" ]; then
      skip=1
      break
    fi
  done

  if [ $exclude_spot -eq 1 ] && [ "$job_type" == "spot" ]; then
    skip=1
  fi

  if [ $skip -eq 0 ]; then
    echo "$line"
    # 增加计数器
    count=$((count + 1))
    # 如果启用了取消操作，取消此任务
    if [ $cancel_jobs -eq 1 ]; then
      sudo scancel "$job_id"
      echo "Cancelled job ID $job_id"
    fi
  fi
done < "$tempfile"

echo "Total lines: $count"

# 删除临时文件
rm "$tempfile"
