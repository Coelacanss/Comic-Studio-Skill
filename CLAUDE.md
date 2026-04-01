# Comic Studio — AI 漫画创作工作室

## Language / 沟通语言

- **主要使用中文**与用户沟通（解释、提问、状态更新等）
- AI 绘图提示词使用英文，附中文翻译
- 文件名、技术术语可保留英文

AI 漫画创作流水线，通过 10 个 skill + 7 个 agent 引导用户从零完成漫画的全流程设计。
从概念孵化到逐格分镜提示词输出，覆盖故事、角色、世界观、视觉风格、分镜的完整链条。

## Technology Stack

- **AI 绘图工具**: Nano Banana Pro（主用）
- **创作流程**: 全流程 Markdown 文档驱动
- **提示词格式**: 英文提示词 + 中文翻译，适配 Nano Banana Pro
- **版本管理**: Git（可选）

## Project Structure

@.claude/docs/directory-structure.md

## Collaboration Protocol

**用户驱动的协作，不是自主执行。**
每个任务遵循：**提问 → 选项 → 决策 → 草稿 → 确认**

- Agent 在写入文件前必须询问「我可以写入 [filepath] 吗？」
- Agent 必须在请求确认前展示草稿或摘要
- 多文件变更需要对完整变更集的明确确认
- 修改现有文件时必须展示「变更影响清单」

> **第一次使用？** 运行 `/start` 开始引导式入门流程。

## Agent Roster

@.claude/docs/agent-roster.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Skills Reference

@.claude/docs/skills-reference.md

## Core Workflow

```
start → brainstorm → design-world → design-character
                                          ↓
                     style-guide ← ← ← ← ┘
                         ↓
                   plot-architecture → episode-design → storyboard
                                                           ↓
                                          story-review ← ← ┘
                                               ↓
                                          gate-check
```

每个 skill 完成后写入 `production/session-state.md`，`/start` 读取它来恢复上下文。

## Modification Protocol

当任何上游文件被修改时，执行修改的 skill 必须：

1. 展示当前内容，与用户确认修改范围
2. 执行修改
3. 输出「变更影响清单」（列出受影响的下游文件 + 建议操作）
4. 同步更新直接关联的产出文件
5. 更新 session-state.md（在「待处理事项」中登记未同步的下游文件）
