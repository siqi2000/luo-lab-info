#!/bin/bash
# GPU 状态监控脚本 - JSON 输出版
# 仅调用 nvidia-smi，不占用 GPU，CPU/内存消耗可忽略
# 输出格式供 push_to_notion.py 推送到 Notion 消费
# 部署：复制到每台服务器，cron 定时执行并写入可访问路径

HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 生成 GPU 数组
GPU_LIST=""
gpu_first=1
while IFS=',' read -r idx name mem_used mem_total util; do
  idx=$(echo "$idx" | tr -d ' ')
  name=$(echo "$name" | tr -d ' ')
  mem_used=$(echo "$mem_used" | tr -d ' ')
  mem_total=$(echo "$mem_total" | tr -d ' ')
  util=$(echo "$util" | tr -d ' ')
  [ -z "$util" ] && util=0
  [ $gpu_first -eq 1 ] && gpu_first=0 || GPU_LIST="$GPU_LIST,"
  GPU_LIST="$GPU_LIST{\"index\":$idx,\"name\":\"$name\",\"memory_used\":$mem_used,\"memory_total\":$mem_total,\"utilization\":$util}"
done < <(nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

# 生成进程数组
PROC_LIST=""
proc_first=1
while read -r line; do
  pid=$(echo "$line" | cut -d',' -f1 | tr -d ' ')
  mem=$(echo "$line" | cut -d',' -f2 | tr -d ' ' | tr -d 'MiB')
  [ -z "$pid" ] && continue
  user=$(ps -p $pid -o user= 2>/dev/null || echo "unknown")
  cmd=$(ps -p $pid -o cmd= 2>/dev/null | head -c 50 | sed 's/"/\\"/g')
  [ $proc_first -eq 1 ] && proc_first=0 || PROC_LIST="$PROC_LIST,"
  PROC_LIST="$PROC_LIST{\"pid\":$pid,\"user\":\"$user\",\"memory_mb\":$mem,\"gpu_index\":0,\"command\":\"$cmd\"}"
done < <(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader 2>/dev/null)

# 输出完整 JSON
echo "{\"hostname\":\"$HOSTNAME\",\"timestamp\":\"$TIMESTAMP\",\"gpus\":[$GPU_LIST],\"processes\":[$PROC_LIST]}"
