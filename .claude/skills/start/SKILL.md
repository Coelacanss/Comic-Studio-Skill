---
name: start
description: "漫画项目入口 — 扫描项目状态，诊断缺口，推荐下一步操作。"
argument-hint: "[无参数]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
---

# 引导式入门

这是 Comic Studio 的入口 skill。它不假设用户有任何漫画创意或创作经验。
先诊断项目状态，再引导用户进入正确的工作流。

---

## 工作流

### 1. 静默诊断项目状态

在向用户提问之前，先静默收集项目上下文。这些结果用于辅助推荐，不直接展示。

检查项：
- **session-state.md 存在？** 读取 `comic-project/production/session-state.md`
- **企划书存在？** 检查 `comic-project/concept/comic-concept.md`
- **世界观存在？** 检查 `comic-project/design/world/worldbook.md`
- **角色索引存在？** 检查 `comic-project/design/characters/character-index.md`
- **角色卡数量？** Glob `comic-project/design/characters/*.md`（排除 index）
- **风格指南存在？** 检查 `comic-project/design/style-guide.md`
- **故事结构存在？** 检查 `comic-project/design/story/story-structure.md`
- **分话索引存在？** 检查 `comic-project/design/story/episode-index.md`
- **分话设计数量？** Glob `comic-project/design/story/ep*-design.md`
- **分镜数量？** Glob `comic-project/storyboard/ep*/ep*-script.md`
- **审查报告？** Glob `comic-project/reviews/*.md`
- **提示词文件？** Glob `comic-project/prompts/*.md`

按**门禁顺序**逐级检查，识别第一个缺口。

---

### 2. 分流：新项目 vs 继续项目

#### 如果项目目录不存在或为空

> **欢迎来到 Comic Studio！**
>
> 我是你的 AI 漫画创作助手，会引导你从零开始完成漫画的全流程设计——
> 从灵感到分镜提示词。
>
> 你现在处于什么状态？
>
> **A) 完全没想法** — 想做漫画，但还没有任何概念
>
> **B) 有模糊灵感** — 脑子里有些碎片（「末日题材」「校园悬疑」之类），但不具体
>
> **C) 有明确想法** — 知道要画什么故事，有基本的人物和情节构思，但没有文档化
>
> **D) 已有素材** — 已经写了一些设定、大纲、或角色设计，想整理和继续推进

等待用户回答，不要自动推进。

---

#### 如果 session-state.md 存在（继续项目）

1. 读取 session-state.md，提取：
   - 当前阶段
   - 最后操作
   - 中断点（如有）
   - 待处理事项（如有）
2. 展示恢复摘要：
   > **欢迎回来！**
   >
   > 你的漫画项目「{项目名称}」当前在 **{阶段}** 阶段。
   >
   > 上次操作：{skill名} — {摘要}
   >
   > {如有中断点：「上次在 {描述} 处中断，可以从这里继续。」}
   >
   > {如有待处理事项：「有 N 项待处理事项需要注意。」}
3. 执行时序一致性快检（对比关键文件的修改时间），如有异常则警告
4. 推荐下一步操作

---

### 3. 路由逻辑

#### A) 完全没想法

1. 表示从零开始完全没问题
2. 简要介绍 `/brainstorm` 的作用
3. 推荐路径：
   - `/brainstorm` — 孵化漫画概念
   - `/design-world` — 构建世界观
   - `/design-character` — 设计角色
   - `/style-guide` — 定义视觉风格
   - `/plot-architecture` — 规划故事结构
   - 后续按话循环 `/episode-design` → `/storyboard`

#### B) 有模糊灵感

1. 请用户分享灵感碎片，哪怕只是几个词
2. 肯定这些碎片作为起点的价值
3. 推荐运行 `/brainstorm` 并附上用户的灵感关键词

#### C) 有明确想法

1. 追问 2-3 个问题：
   - 什么类型/题材？一句话描述核心故事
   - 大概多少角色？有没有想好主角
   - 预估是短篇（1-5话）、中篇（6-20话）还是长篇（20+话）
2. 推荐两条路径：
   - **先正式化**: 运行 `/brainstorm` 把想法结构化为企划书
   - **跳到世界观**: 如果概念已足够清晰，可以手写 comic-concept.md 后直接进 `/design-world`

#### D) 已有素材

1. 展示诊断结果：已检测到的文件和状态
2. 执行缺口分析：
   - 按流程顺序列出每个阶段的文件状态（✅ 存在 / ❌ 缺失 / ⚠ 可能过时）
3. 推荐从第一个缺口处继续

---

### 4. 确认后交接

推荐路径后，询问用户想从哪一步开始。绝不自动执行下一个 skill。

> 「你想从 {推荐的第一步} 开始吗？或者你更想先做别的？」

---

### 5. 边界情况

- **用户选 D 但项目为空**: 温和引导到 A 或 B
- **用户选 A 但已有文件**: 提及检测到的文件，确认是否要重新开始
- **返回用户且所有阶段已完成**: 引导进入下一话的 `/episode-design` 或全面 `/story-review`
- **用户情况不匹配任何选项**: 让用户自由描述，灵活适配

---

## 协作协议

1. **先问后答** — 不假设用户的状态或意图
2. **提供选项** — 给出清晰路径，不是命令
3. **用户决定** — 用户选择方向
4. **不自动执行** — 推荐下一个 skill，但不替用户运行
5. **灵活适配** — 用户的情况不匹配模板时，倾听并调整
