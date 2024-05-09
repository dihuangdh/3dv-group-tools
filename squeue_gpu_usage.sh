#!/bin/bash

# 确保使用正确的 squeue 命令路径
squeue_cmd="/usr/bin/squeue"

# 使用 squeue 和 grep 获取 Ai4sci_3D 的结果
result=$($squeue_cmd | grep Ai4sci_3D)

# 初始化一个空的数组来存储用户的 GPU 使用情况
declare -A gpu_usage

# 解析 squeue 结果
while IFS= read -r line; do
  # 提取用户名和 GPU 数量
  user=$(echo "$line" | awk '{print $5}')
  gpu=$(echo "$line" | awk '{print $(NF-1)}' | grep -oP 'gpu:\d+' | cut -d':' -f2)
  state=$(echo "$line" | awk '{print $7}')

  # 如果用户和 GPU 数量有效，则更新数组
  if [[ -n "$user" && -n "$gpu" ]]; then
    if [[ $state == "PD" ]]; then
      gpu_usage["$user,PD"]=$((gpu_usage["$user,PD"] + gpu))
    else
      gpu_usage["$user,R"]=$((gpu_usage["$user,R"] + gpu))
    fi
  fi
done <<< "$result"

# 输出统计结果
echo "User       | PD GPU Count | R GPU Count"
echo "-----------|--------------|-------------"
users=$(for key in "${!gpu_usage[@]}"; do echo "$key" | cut -d',' -f1; done | sort -u)
for user in $users; do
  pd_count=${gpu_usage["$user,PD"]}
  r_count=${gpu_usage["$user,R"]}

  # 处理 PD 和 R 的默认值
  [[ -z "$pd_count" ]] && pd_count=0
  [[ -z "$r_count" ]] && r_count=0

  printf "%-10s | %-12d | %-11d\n" "$user" "$pd_count" "$r_count"
done