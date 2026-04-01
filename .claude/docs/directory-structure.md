# 项目目录结构

```
comic-project/
├── concept/
│   └── comic-concept.md                ← brainstorm 产出
├── design/
│   ├── world/
│   │   └── worldbook.md                ← design-world 产出
│   ├── characters/
│   │   ├── character-index.md           ← design-character 产出
│   │   ├── {name}.md                   ← design-character 逐角色产出
│   │   └── ...
│   ├── style-guide.md                  ← style-guide 产出
│   └── story/
│       ├── story-structure.md           ← plot-architecture 产出
│       ├── episode-index.md             ← plot-architecture 产出
│       ├── ep01-design.md               ← episode-design 产出
│       ├── ep02-design.md
│       └── ...
├── storyboard/
│   ├── ep01/
│   │   ├── ep01-script.md               ← storyboard 叙述版
│   │   └── ep01-table.md                ← storyboard 表格版
│   ├── ep02/
│   └── ...
├── prompts/
│   ├── character-prompts.md             ← design-character 汇总
│   ├── scene-prompts.md                 ← design-world 汇总
│   └── ep01-panel-prompts.md            ← storyboard 逐话汇总
├── production/
│   ├── session-state.md                 ← 所有 skill 写入，start 读取
│   ├── change-log.txt                   ← hook 自动记录
│   ├── session-log.txt                  ← hook 自动记录
│   └── gate-checks/
│       └── {gate-name}.md               ← gate-check 产出
└── reviews/
    └── ep01-review.md                   ← story-review 产出
```

## 目录职责

| 目录 | 职责 | 主要写入者 |
|------|------|-----------|
| `concept/` | 企划概念 | brainstorm |
| `design/world/` | 世界观设定 | design-world |
| `design/characters/` | 角色设定 | design-character |
| `design/story/` | 故事结构与分话设计 | plot-architecture, episode-design |
| `storyboard/` | 分镜脚本 | storyboard |
| `prompts/` | AI 绘图提示词汇总 | design-character, design-world, storyboard |
| `production/` | 项目管理状态 | 所有 skill |
| `reviews/` | 审查报告 | story-review |
