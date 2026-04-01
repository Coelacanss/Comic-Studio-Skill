---
name: gate-check
description: "阶段门禁验证 — 检查文件齐备性、review 状态、时序一致性，给出 PASS/CONCERNS/FAIL 判定。"
argument-hint: "[目标门禁，如 'concept-to-world', 'world-to-character'，或留空自动检测]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
---

# 阶段门禁验证

验证项目是否准备好推进到下一阶段。
检查文件齐备性、审查状态、时序一致性。

---

## 创作阶段定义

```
1. 企划 (Concept)
2. 世界观 (World Building)
3. 角色设计 (Character Design)
4. 故事结构 (Story Structure)
5. 分话设计 (Episode Design) ←→ 分镜 (Storyboard) [逐话循环]
6. 审查通过 (Review Passed)
```

---

## 1. 解析参数

- **有参数**: 检查指定的门禁
- **无参数**: 自动检测当前阶段（基于文件存在性），检查下一个门禁

**门禁列表**:
| 门禁代号 | 含义 |
|---------|------|
| `concept-to-world` | 企划 → 世界观 |
| `world-to-character` | 世界观 → 角色设计 |
| `character-to-story` | 角色设计 → 故事结构 |
| `story-to-episode` | 故事结构 → 分话设计 |
| `episode-to-storyboard` | 分话设计 → 分镜（需指定话数） |
| `storyboard-to-done` | 分镜 → 完成（需指定话数） |

---

## 2. 门禁定义

### 企划 → 世界观

**必须存在的文件**:
- [ ] `comic-project/concept/comic-concept.md`

**质量检查**:
- [ ] 企划书包含所有必须字段（电梯演讲、核心冲突、核心情感、主题方向、故事前提、角色速写、世界观速写、结局方向、预估规模、单话目标页数）
- [ ] 每个字段有实质内容（不是空的或占位符）

---

### 世界观 → 角色设计

**必须存在的文件**:
- [ ] `comic-project/design/world/worldbook.md`
- [ ] `comic-project/prompts/scene-prompts.md`

**质量检查**:
- [ ] worldbook 包含核心规则（至少 3 条）
- [ ] worldbook 包含场景列表（至少 3 个场景）
- [ ] scene-prompts 中每个场景都有英文提示词

---

### 角色设计 → 故事结构

**必须存在的文件**:
- [ ] `comic-project/design/characters/character-index.md`
- [ ] 至少 2 个角色卡 `comic-project/design/characters/{name}.md`
- [ ] `comic-project/prompts/character-prompts.md`

**质量检查**:
- [ ] 有主角角色卡且包含完整内心引擎（Want/Need/Lie/Flaw/弧线方向）
- [ ] 有对手/主要冲突源角色卡
- [ ] 角色关系网络已建立
- [ ] character-prompts 中每个角色都有外貌锚定词

---

### 故事结构 → 分话设计

**必须存在的文件**:
- [ ] `comic-project/design/story/story-structure.md`
- [ ] `comic-project/design/story/episode-index.md`

**质量检查**:
- [ ] story-structure 包含幕结构和主线弧线
- [ ] story-structure 包含主题论证追踪
- [ ] episode-index 列出所有话（和预估规模匹配）
- [ ] 至少有张力节奏总览

---

### 分话设计 → 分镜（逐话）

**必须存在的文件**:
- [ ] `comic-project/design/story/ep{N}-design.md`
- [ ] `comic-project/design/style-guide.md`

**质量检查**:
- [ ] ep{N}-design 包含所有必须部分（任务清单、场景列表、情绪地图、钩子设计）
- [ ] 页面预算通过（实际页数在目标 ±2 页范围内）
- [ ] 至少有一个话尾钩子

---

### 分镜 → 完成（逐话）

**必须存在的文件**:
- [ ] `comic-project/storyboard/ep{N}/ep{N}-script.md`
- [ ] `comic-project/storyboard/ep{N}/ep{N}-table.md`
- [ ] `comic-project/prompts/ep{N}-panel-prompts.md`

**质量检查**:
- [ ] script 包含结束状态摘要
- [ ] table 的行数和 script 的格数匹配
- [ ] panel-prompts 的条目数和总格数匹配
- [ ] review 存在且判定为「通过」或「需修改」（已修改完成）

---

## 3. 时序一致性检查（所有门禁通用）

使用 `Bash` 获取相关文件的最后修改时间，按依赖关系检查：

```
上游文件比下游文件更新 = 可能的时序问题

检查链:
comic-concept.md → worldbook.md → 角色卡 → story-structure.md
  → ep{N}-design.md → ep{N}-script.md → ep{N}-review.md
```

如果发现时序不一致：
- ⚠ 「{上游文件} 在 {下游文件} 之后被修改过，{下游文件} 可能需要同步更新」

---

## 4. 输出判定

```markdown
## 门禁检查: {当前阶段} → {目标阶段}

**日期**: {date}

### 文件检查: [{X}/{Y} 通过]
- [x] comic-concept.md — 存在，{大小}
- [ ] worldbook.md — ❌ 缺失

### 质量检查: [{X}/{Y} 通过]
- [x] 企划书字段完整
- [ ] 角色关系网络 — ❌ 未建立

### 时序一致性: [{X} 条警告]
- ⚠ comic-concept.md (2026-03-28) 比 worldbook.md (2026-03-25) 更新

### 阻塞项
1. {阻塞描述} — 建议操作: {具体操作}
2. ...

### 建议
- {优先操作}
- {可选改进}

### 判定: {PASS / CONCERNS / FAIL}
- **PASS**: 所有文件齐备，所有检查通过
- **CONCERNS**: 文件齐备但有时序警告或非关键质量问题
- **FAIL**: 缺少必须文件或有关键质量问题
```

---

## 5. PASS 后更新

当判定为 PASS 且用户确认推进：

1. 写入门禁报告到 `comic-project/production/gate-checks/{gate-name}.md`
2. 更新 `production/session-state.md` 的当前阶段

---

## 6. 后续建议

根据判定结果推荐下一步：

- **PASS**: 「可以进入 {下一阶段}，建议运行 /{对应skill}」
- **CONCERNS**: 「建议先处理时序警告，再推进。或者接受风险继续。」
- **FAIL**: 按阻塞项逐条建议需要运行的 skill

---

## 协作协议

1. **全面检查** — 不跳过任何检查项
2. **时序敏感** — 时序不一致是常见的隐性问题，必须检查
3. **判定是建议** — 最终是否推进由用户决定
4. **不阻塞用户** — 即使 FAIL 也允许用户选择继续，但记录风险
5. **写入前确认** — 询问是否写入门禁报告
