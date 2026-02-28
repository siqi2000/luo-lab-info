# GPU 监控脚本

## 使用说明

`gpu_monitor_json.sh` 在每台服务器上运行，采集 GPU 状态并输出 JSON。配合 `push_to_notion.py` 可将数据推送到 Notion 数据库。

### 部署步骤

1. 复制脚本到服务器：
   ```bash
   scp gpu_monitor_json.sh 用户@服务器:/home/用户/
   ```

2. 添加执行权限：
   ```bash
   chmod +x gpu_monitor_json.sh
   ```

3. 测试运行：
   ```bash
   ./gpu_monitor_json.sh
   ```

4. 配合 `push_to_notion.py` 使用，详见根目录 `部署指南.md`。

### 输出格式

```json
{
  "hostname": "server01",
  "timestamp": "2025-02-28 14:30:00",
  "gpus": [
    {"index": 0, "name": "RTX 4090", "memory_used": 23475, "memory_total": 24564, "utilization": 0}
  ],
  "processes": [
    {"pid": 222450, "user": "gdtest", "memory_mb": 23468, "gpu_index": 0, "command": "VLLM::Worker_TP0"}
  ]
}
```
