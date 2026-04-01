#!/bin/bash
# Session Start Hook - 读取项目状态并输出恢复信息

PROJECT_DIR="$(pwd)"
STATE_FILE="$PROJECT_DIR/comic-project/production/session-state.md"

if [ -f "$STATE_FILE" ]; then
  echo "=== Comic Studio 会话恢复 ==="
  # 提取关键状态信息
  STAGE=$(grep -m1 "^- 当前阶段" "$STATE_FILE" 2>/dev/null | sed 's/^- 当前阶段[：:] *//')
  LAST_SKILL=$(grep -m1 "执行的 skill" "$STATE_FILE" 2>/dev/null | sed 's/.*skill[：:] *//')
  LAST_SUMMARY=$(grep -m1 "操作内容摘要" "$STATE_FILE" 2>/dev/null | sed 's/.*摘要[：:] *//')

  [ -n "$STAGE" ] && echo "当前阶段: $STAGE"
  [ -n "$LAST_SKILL" ] && echo "上次操作: $LAST_SKILL"
  [ -n "$LAST_SUMMARY" ] && echo "操作内容: $LAST_SUMMARY"

  # 检查是否有待处理事项
  if grep -q "待处理事项" "$STATE_FILE" 2>/dev/null; then
    echo "⚠ 存在待处理事项，建议运行 /start 查看详情"
  fi
else
  # 检查项目是否存在
  if [ -d "$PROJECT_DIR/comic-project" ]; then
    echo "=== Comic Studio: 项目目录存在但无会话状态 ==="
    echo "建议运行 /start 进行项目状态诊断"
  else
    echo "=== Comic Studio: 未检测到项目 ==="
    echo "运行 /start 开始创建你的漫画项目"
  fi
fi
