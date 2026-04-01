#!/bin/bash
# Session Stop Hook - 会话结束时的清理工作
# 注意：此 hook 运行时 Claude 已无法响应，仅做轻量记录

PROJECT_DIR="$(pwd)"
LOG_FILE="$PROJECT_DIR/comic-project/production/session-log.txt"

if [ -d "$PROJECT_DIR/comic-project/production" ]; then
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$TIMESTAMP] Session ended" >> "$LOG_FILE"
fi
