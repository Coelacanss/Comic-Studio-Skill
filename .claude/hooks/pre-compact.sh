#!/bin/bash
# PreCompact Hook - 上下文压缩前保存关键信息

PROJECT_DIR="$(pwd)"
STATE_FILE="$PROJECT_DIR/comic-project/production/session-state.md"

if [ -f "$STATE_FILE" ]; then
  echo "=== PreCompact: 关键上下文保存 ==="
  echo "session-state.md 存在于: comic-project/production/session-state.md"
  echo "压缩后请读取 session-state.md 恢复完整上下文"

  # 输出当前阶段和待处理事项作为压缩后的恢复线索
  STAGE=$(grep -m1 "^- 当前阶段" "$STATE_FILE" 2>/dev/null | sed 's/^- 当前阶段[：:] *//')
  [ -n "$STAGE" ] && echo "当前阶段: $STAGE"
fi
