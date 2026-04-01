#!/bin/bash
# PostToolUse Hook - 追踪文件变更
# 当 comic-project/ 下的文件被写入或编辑时，记录变更日志

TOOL_INPUT="$CLAUDE_TOOL_INPUT"
PROJECT_DIR="$(pwd)/comic-project"

# 提取文件路径（从 tool input 中）
FILE_PATH=$(echo "$TOOL_INPUT" | grep -oP '"file_path"\s*:\s*"([^"]*)"' | head -1 | sed 's/.*"file_path"\s*:\s*"//;s/"$//')

# 只追踪 comic-project 目录下的文件
if echo "$FILE_PATH" | grep -q "comic-project"; then
  LOG_DIR="$PROJECT_DIR/production"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/change-log.txt"
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  RELATIVE_PATH=$(echo "$FILE_PATH" | sed "s|.*comic-project/||")
  echo "[$TIMESTAMP] $RELATIVE_PATH" >> "$LOG_FILE"
fi
