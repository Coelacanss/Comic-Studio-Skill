# Skills Reference

Comic Studio 提供 10 个 skill，覆盖漫画创作全流程。

## 流程 Skills（按工作流顺序）

| Skill | 职责 | 产出文件 |
|-------|------|---------|
| `/start` | 入口路由，扫描项目状态，推荐下一步 | 无（仅路由） |
| `/brainstorm` | 从零孵化漫画核心概念 | `concept/comic-concept.md` |
| `/design-world` | 7 阶段引导建立世界观 | `design/world/worldbook.md` + `prompts/scene-prompts.md` |
| `/design-character` | 逐角色引导设计 | `design/characters/*.md` + `prompts/character-prompts.md` |
| `/style-guide` | 定义全局视觉风格与 AI 工具配置 | `design/style-guide.md` |
| `/plot-architecture` | 故事结构设计与分话规划 | `design/story/story-structure.md` + `design/story/episode-index.md` |
| `/episode-design` | 单话详细设计 | `design/story/ep{N}-design.md` |
| `/storyboard` | 逐页逐格分镜 + AI 提示词 | `storyboard/ep{N}/*.md` + `prompts/ep{N}-panel-prompts.md` |

## 审查 Skills

| Skill | 职责 | 产出文件 |
|-------|------|---------|
| `/story-review` | 交叉验证文档一致性 | `reviews/ep{N}-review.md` |
| `/gate-check` | 阶段门禁验证 + 时序检查 | `production/gate-checks/{gate-name}.md` |

## 依赖关系

```
start ──→ brainstorm ──→ design-world ──→ design-character
                              │                  │
                              └──→ style-guide ←──┘
                                       │
                              plot-architecture
                                       │
                              episode-design ←→ storyboard
                                                    │
                                              story-review
                                                    │
                                               gate-check
```

## 通用行为

- 所有 skill 完成后写入 `production/session-state.md`
- 修改现有文件时输出「变更影响清单」
- 遵循协作协议：提问 → 选项 → 决策 → 草稿 → 确认
