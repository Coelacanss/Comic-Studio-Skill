# Agent Roster

以下 agent 可用于漫画创作流程。每个 agent 在 `.claude/agents/` 下有独立定义文件。
当任务跨越多个领域时，由对应的领域 agent 委托给专家 agent。

## Tier 1 — 创意总监 (Opus)

| Agent | 领域 | 何时使用 |
|-------|------|---------|
| `story-architect` | 故事结构与主题 | 重大剧情决策、主题方向、弧线冲突、结构调整 |

## Tier 2 — 部门主管 (Sonnet)

| Agent | 领域 | 何时使用 |
|-------|------|---------|
| `character-designer` | 角色设计 | 角色内心引擎、反应模式、弧线设计、关系网络 |
| `world-builder` | 世界观构建 | 世界规则、空间结构、势力关系、历史设定 |
| `art-director` | 视觉风格 | 画风定义、色彩方案、分格规范、视觉一致性 |
| `storyboard-artist` | 分镜设计 | 镜头语言、构图、页面节奏、翻页设计 |
| `editor` | 审查与一致性 | 角色行为/语言一致性、世界规则一致性、伏笔追踪 |
| `prompt-engineer` | AI 提示词 | 提示词优化、Nano Banana Pro 适配、角色一致性方案 |

## Agent 使用原则

- Skill 可以调用 agent 来处理子任务（如 `storyboard` 调用 `storyboard-artist`）
- Agent 不直接面向用户，由 skill 编排调用
- Agent 间通过文件系统通信，不直接调用彼此
- 冲突升级路径：专家 → 部门主管 → `story-architect`
