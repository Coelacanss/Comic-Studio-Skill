# 漫画创作流水线架构

---

## 全局文件结构

```
comic-project/
├── concept/
│   └── comic-concept.md                ← brainstorm
├── design/
│   ├── world/
│   │   └── worldbook.md                ← design-world
│   ├── characters/
│   │   ├── character-index.md           ← design-character
│   │   ├── xiaoyao.md                  ← design-character（逐角色）
│   │   ├── old-k.md                    ← design-character（逐角色）
│   │   └── ...
│   ├── style-guide.md                  ← style-guide
│   └── story/
│       ├── story-structure.md           ← plot-architecture
│       ├── episode-index.md             ← plot-architecture
│       ├── ep01-design.md               ← episode-design
│       ├── ep02-design.md               ← episode-design
│       └── ...
├── storyboard/
│   ├── ep01/
│   │   ├── ep01-script.md               ← storyboard（叙述版）
│   │   └── ep01-table.md                ← storyboard（表格版）
│   ├── ep02/
│   └── ...
├── prompts/
│   ├── character-prompts.md             ← design-character（汇总）
│   ├── scene-prompts.md                 ← design-world（汇总）
│   └── ep01-panel-prompts.md            ← storyboard（逐话汇总）
├── production/
│   ├── session-state.md                 ← 所有 skill 写入，start-comic 读取
│   └── gate-checks/
│       └── concept-to-preproduction.md  ← gate-check
└── reviews/
    └── ep01-review.md                   ← story-review
```

---

## 逐 Skill 详细拆解

### 1. `start-comic`

| | 内容 |
|---|---|
| **职责** | 入口路由。调用 `project-detect` 的诊断逻辑，扫描项目状态，向用户推荐下一步 |
| **依赖的文件（读取）** | `production/session-state.md`（如存在）；扫描整个 `comic-project/` 目录结构 |
| **依赖的 skill 产出** | 无（它是入口） |
| **自身产出文件** | 无文件产出（只做路由和推荐） |
| **产出内容** | 项目状态诊断报告 + 推荐下一步应执行的 skill |
| **下游消费者** | 无 |
| **与 `project-detect` 的关系** | `start-comic` 内置 `project-detect` 的全部诊断逻辑。`project-detect` 不再作为独立 skill 存在，其功能被 `start-comic` 完全吸收 |

**`start-comic` 的诊断逻辑（原 `project-detect`）：**

```
1. 扫描 comic-project/ 目录，列出已存在的文件清单
2. 读取 session-state.md（如存在），获取上次中断点
3. 按门禁顺序逐级检查：
   - comic-concept.md 是否存在且完整？
   - worldbook.md + scene-prompts.md 是否存在？
   - character-index.md + 各角色卡 + character-prompts.md 是否存在？
   - story-structure.md + episode-index.md 是否存在？
   - 各话的 ep{N}-design.md / storyboard / review 状态？
4. 识别缺口：哪些文件缺失或上游比下游更新（时序不一致）
5. 输出：
   - 当前阶段判定
   - 缺口列表
   - 时序不一致警告（如有）
   - 推荐下一步操作
```

---

### 2. `brainstorm`

| | 内容 |
|---|---|
| **职责** | 从零开始，引导用户孵化漫画核心概念 |
| **依赖的文件** | 无（从零开始）；如果存在 `comic-concept.md`，读取并续写而非重建 |
| **依赖的 skill 产出** | 无 |
| **自身产出文件** | `concept/comic-concept.md` |
| **产出内容** | 见下方详细字段 |
| **下游消费者** | `design-world`、`design-character`、`style-guide`、`plot-architecture` 全部读取它 |
| **完成后更新** | 写入 `production/session-state.md` |

**`comic-concept.md` 包含的字段：**

```
- 作品名称（暂定）
- 类型/题材标签（末日/冒险/悬疑...）
- 目标读者画像
- 电梯演讲（1-2句核心卖点）
- 核心冲突（一句话概括）
- 核心情感（读者应获得的主要情绪体验）
- 主题方向（故事想探讨什么）
- 故事前提（用"如果……会怎样"的句式）
- 主要角色速写（名字+一句话定位，不展开）
- 世界观速写（核心概念，不展开）
- 结局方向（胜利/代价/开放/悲剧）
- 预估规模（短篇/中篇/长篇）
- 单话目标页数（如：24页、32页，或浮动范围如24-28页）  ← [新增]
- 参考作品（调性/风格/结构上的参照）
- 最大风险（这个企划最可能失败的原因）
```

**修改模式行为：**

```
当 comic-concept.md 已存在且用户要求修改时：
1. 读取现有文件，展示当前内容
2. 引导用户确认修改范围
3. 完成修改后，输出「变更影响清单」：
   - 列出所有读取 comic-concept.md 的下游文件
   - 逐条判断：本次修改是否影响该下游文件
   - 对受影响的文件标注"需要同步更新"
4. 更新 session-state.md
```

---

### 3. `design-world`

| | 内容 |
|---|---|
| **职责** | 7 阶段引导，建立完整世界观 |
| **依赖的文件** | `concept/comic-concept.md`（必须存在） |
| **依赖的 skill 产出** | `brainstorm` 的企划书（世界观速写、核心冲突、类型/题材） |
| **自身产出文件** | ① `design/world/worldbook.md`  ② `prompts/scene-prompts.md` |
| **下游消费者** | `design-character`、`style-guide`、`plot-architecture`、`episode-design`、`storyboard`、`story-review` |
| **完成后更新** | 写入 `production/session-state.md` |

**`worldbook.md` 包含的字段：**

```
- 世界概述（一段话总览）
- 核心规则列表
  - 每条规则：规则名、规则内容、制造的限制、制造的选择、叙事价值
- 空间结构
  - 大地图概览
  - 场景列表，每个场景：
    - 场景名
    - 视觉描述（中文）
    - 情绪调性
    - 典型场景类型（什么样的剧情会在这里发生）
    - 视觉锚定提示词（英文，附中文翻译）
- 势力/社会结构
  - 每个势力：名称、立场、与主角的关系、内部矛盾
- 日常生活细节（食物、教育、娱乐、夜晚景象）
- 历史/创世事件
  - 真相（可标记为"暂定"或"开放"）
  - 官方说法（世界内的居民相信的版本）
  - 真相与官方说法的差距 = 悬念素材
- 开放问题列表（没定论的设定，留待后续）
```

**`scene-prompts.md` 包含的字段：**

```
- 场景名 → 英文提示词 + 中文翻译（逐场景）
- 全局环境氛围词（会被 storyboard 在每格提示词中引用）
```

**修改模式行为：**

```
当 worldbook.md 已存在且用户要求修改时：
1. 读取现有文件，定位修改目标
2. 完成修改后，输出「变更影响清单」：
   - 若修改了核心规则 → 标记所有角色卡中"与世界规则的交互"需复查，
     标记 story-structure.md 需复查
   - 若修改了场景列表 → 标记 scene-prompts.md 需同步更新，
     标记所有引用该场景的 ep{N}-design.md 和 storyboard 需复查
   - 若修改了势力结构 → 标记 character-index.md 的关系网络需复查
3. 同步更新 scene-prompts.md（如场景有变）
4. 更新 session-state.md
```

---

### 4. `design-character`

| | 内容 |
|---|---|
| **职责** | 逐角色引导设计，产出角色卡和视觉提示词 |
| **依赖的文件** | ① `concept/comic-concept.md` ② `design/world/worldbook.md` |
| **依赖的 skill 产出** | `brainstorm`（角色速写、核心冲突）+ `design-world`（世界规则、势力结构——角色必须在世界规则内运行） |
| **自身产出文件** | ① `design/characters/character-index.md` ② `design/characters/{name}.md`（每角色一个） ③ `prompts/character-prompts.md` |
| **下游消费者** | `plot-architecture`、`episode-design`、`storyboard`、`story-review` |
| **完成后更新** | 写入 `production/session-state.md` |

**`character-index.md` 包含的字段：**

```
- 角色总表
  | 角色名 | 故事功能 | 阵营/势力 | 首次登场话 | 设计状态 | 文件链接 |
- 角色关系网络
  | 角色A | 角色B | 关系 | 张力来源 | 可能的发展方向 |
```

**每个 `{name}.md` 包含的字段：**

```
- 基础信息（名字、年龄、性别、职业/身份）
- 叙事功能（主角/对手/导师/盟友/变节者/...）
- 内心引擎
  - 欲望（Want）：外在目标
  - 需求（Need）：内在成长方向（角色自己不知道）
  - 谎言（Lie）：角色相信的错误信念
  - 缺陷（Flaw）：导致问题的性格特质
  - 弧线方向：从 A 到 B 的变化
- 性格反应模式
  | 情境类型 | 反应方式 | 原因 |
  面对危险→ / 面对善意→ / 面对背叛→ / 情绪崩溃点→
- 语言画像  ← [新增]
  - 语域：书面语 / 口语 / 混合
  - 句式倾向：长句（思辨型）/ 短句（行动型）/ 碎片式（情绪型）
  - 用语习惯：方言词汇、专业术语、年代感用语、外来语
  - 口头禅/标志性句式
  - 典型台词示例（3句）
    - 日常状态下的台词
    - 压力状态下的台词
    - 情绪爆发时的台词
- 与世界规则的交互
  - 这个角色和哪条世界规则有特殊关系？
  - 例：小鹿是半变异体 → 和"雾蚀规则"直接冲突
- 关系网络（本角色视角）
  | 对象 | 关系 | 张力来源 | 可能发展 |
- 标志性特征（外貌以外的识别标记）
  - 习惯性动作
  - 标志性物品
- 外貌设计
  - 整体描述（中文）
  - 标志性表情 3 种：常态/战斗/脆弱
  - 服装描述 + 变化时间线（第几话换装）
- 视觉提示词
  - 外貌锚定词（英文，附中文翻译）
  - 表情变体词（英文，附中文翻译）
```

**`character-prompts.md` 包含的字段：**

```
- 每角色的外貌锚定提示词（英文+中文）
- 每角色的表情变体提示词
- 组合示例（角色+场景+情绪的拼装示范）
```

**修改模式行为：**

```
当某角色卡已存在且用户要求修改时：
1. 读取现有角色卡，定位修改目标
2. 完成修改后，输出「变更影响清单」：
   - 若修改了内心引擎/弧线方向
     → 标记 story-structure.md 的角色弧线追踪需更新
     → 标记所有该角色出场话的 ep{N}-design.md 需复查
   - 若修改了性格反应模式
     → 标记所有该角色出场话的 storyboard 中该角色行为需复查
   - 若修改了外貌/视觉提示词
     → 标记 character-prompts.md 需同步更新
     → 标记所有该角色出场话的 panel-prompts 需重新生成
   - 若修改了关系网络
     → 标记 character-index.md 的关系网络需同步更新
     → 标记相关角色的角色卡中"关系网络"需交叉更新
3. 同步更新 character-index.md 和 character-prompts.md
4. 更新 session-state.md
```

---

### 5. `style-guide`

| | 内容 |
|---|---|
| **职责** | 定义全局视觉风格，产出所有提示词的通用前缀 |
| **依赖的文件** | ① `concept/comic-concept.md` ② `design/world/worldbook.md`（场景调性） |
| **依赖的 skill 产出** | `brainstorm`（类型/题材、参考作品、单话目标页数）+ `design-world`（世界视觉调性） |
| **自身产出文件** | `design/style-guide.md` |
| **下游消费者** | `storyboard`（所有提示词都以 style-guide 的全局前缀开头）、`episode-design`（分格规范影响页面预算） |
| **完成后更新** | 写入 `production/session-state.md` |

**`style-guide.md` 包含的字段：**

```
- 画风定位
  - 风格描述（中文）
  - 风格参考作品
  - 风格关键词（英文提示词前缀，附中文翻译）
    例："manga style, detailed linework, high contrast black and white,
        cinematic lighting"
       (漫画风格，精细线条，高对比黑白，电影感光影)
- 色彩方案
  - 黑白 or 彩色
  - 如果彩色：主色调、辅色调、禁用色
  - 色彩关键词（英文，附中文翻译）
- 线条风格
  - 粗细、清晰度、手绘感 vs 精致感
- 日式漫画规范
  - 页面尺寸：B5（182mm × 257mm）
  - 出血区设定
  - 网点/阴影处理方式
- 分格（Panel Layout）规范  ← [新增]
  - 每页典型格数范围（如：4-6格/页为常态）
  - 分格风格倾向：规整网格式 / 自由破格式 / 混合
  - 场景类型分格策略：
    | 场景类型 | 格数倾向 | 格形状倾向 | 说明 |
    | 安静对话 | 4-5格 | 规整横格 | 节奏稳定，聚焦表情 |
    | 动作场面 | 3-4格 | 斜格/破格/跨页 | 强调动势和冲击 |
    | 情绪高潮 | 1-2格 | 大格/整页/跨页 | 留白，让情绪呼吸 |
    | 日常过渡 | 5-6格 | 小格混排 | 快速推进，不恋战 |
  - 跨页使用原则（什么情况下允许跨页大图）
  - 留白使用原则（什么情况下允许大面积留白）
- 效果线规范（速度线、集中线、情绪线的使用原则）
- 文字气泡规范（对白气泡、旁白框、音效字体的风格）
- 提示词全局前缀模板
  - 用于人物格的前缀
  - 用于场景格的前缀
  - 用于特写格的前缀
```

---

### 6. `plot-architecture`

| | 内容 |
|---|---|
| **职责** | 引导用户讲述故事→推导结构→逐话分配→建立追踪系统 |
| **依赖的文件** | ① `concept/comic-concept.md` ② `design/world/worldbook.md` ③ `design/characters/character-index.md` ④ 所有角色卡 `design/characters/*.md` |
| **依赖的 skill 产出** | `brainstorm`（核心冲突、结局方向、预估规模、主题方向）+ `design-world`（世界规则——决定什么剧情可能发生）+ `design-character`（角色引擎——角色的欲望/缺陷驱动剧情走向；关系网络——关系的张力 = 支线来源） |
| **自身产出文件** | ① `design/story/story-structure.md` ② `design/story/episode-index.md` |
| **下游消费者** | `episode-design`（最直接的消费者）、`storyboard`、`story-review`、`gate-check` |
| **完成后更新** | 写入 `production/session-state.md` |

**`story-structure.md` 包含的字段：**

```
- 结构概览
  - 幕数、每幕话数、总话数
  - 每幕的核心任务和结束标志

- 主线弧线
  | 话 | 剧情目标 | 主角状态变化 | 关键事件 | 在整体中的功能 |

- 支线追踪
  | 支线名 | 关联角色 | 起始话 | 高潮话 | 收束话 | 与主线的交汇点 |

- 角色弧线追踪
  | 角色 | 起点状态 | 转折话 | 终点状态 | 弧线和主线的关系 |

- 主题论证追踪  ← [新增]
  | 阶段 | 话 | 主题触及方式 | 说明 |
  | 提出 | 第1幕 | 以问题/困境形式呈现 | 主角面对的核心困境隐含主题问题 |
  | 正面论证 | 第2幕前半 | 通过某角色/事件展示主题的正面回答 | 例：信任带来的回报 |
  | 反面论证 | 第2幕后半 | 通过某角色/事件展示主题的反面回答 | 例：信任带来的背叛 |
  | 辩证 | 第2幕末-第3幕初 | 正反碰撞，主角动摇 | 读者此时也应陷入思考 |
  | 回答 | 第3幕 | 主角通过最终选择给出作者的回答 | 不必绝对，允许带有代价 |

- 信息揭示时间表
  | 信息 | 真相内容 | 读者知道时间点 | 主角知道时间点 | 揭示方式 | 叙事效果 |

- 伏笔网络
  | 伏笔 | 埋设话 | 埋设位置描述 | 回收话 | 埋设时的伪装 | 回收时的真相 |

- 张力节奏总览（全局层面）
  - 每话的目标张力等级（1-10）
  - 整体的起伏节奏图
```

**`episode-index.md` 包含的字段：**

```
- 每话一行的快速索引
  | 话 | 暂定标题 | 一句话概要 | 所属幕 | 目标张力 | 设计状态 | 文件链接 |
```

**修改模式行为：**

```
当 story-structure.md 已存在且用户要求修改时：
1. 读取现有文件，定位修改目标
2. 完成修改后，输出「变更影响清单」：
   - 若修改了主线弧线的某话
     → 标记该话的 ep{N}-design.md 需更新
     → 如果影响后续话的前提条件，标记后续所有话的 ep{N}-design.md 需复查
   - 若修改了支线追踪
     → 标记涉及话的 ep{N}-design.md 需复查
   - 若修改了伏笔网络
     → 标记伏笔埋设话和回收话的 ep{N}-design.md 及 storyboard 需复查
   - 若修改了角色弧线
     → 标记对应角色卡的弧线方向是否需要同步修改
   - 若增删了话数
     → 标记 episode-index.md 需同步更新
3. 同步更新 episode-index.md
4. 更新 session-state.md
```

---

### 7. `episode-design` ⭐

| | 内容 |
|---|---|
| **职责** | 单话详细设计——叙述策略、情绪地图、爽点笑点钩子 |
| **依赖的文件** | ① `design/story/story-structure.md` ② `design/story/episode-index.md` ③ `design/world/worldbook.md` ④ 本话涉及角色的 `design/characters/*.md` ⑤ 前一话的 `design/story/ep{N-1}-design.md`（如果存在） ⑥ 前一话 storyboard 的「本话结束状态摘要」段落（如果存在） ⑦ `concept/comic-concept.md`（可选参照，非必须读取） |
| **依赖的 skill 产出** | `plot-architecture`（本话的剧情目标、信息揭示计划、伏笔计划、目标张力、主题论证阶段）+ `design-world`（世界规则——场景选择、规则如何在本话产生影响）+ `design-character`（角色反应模式、语言画像——角色在本话情境中应如何行动和说话；关系——本话要推进哪段关系） |
| **自身产出文件** | `design/story/ep{N}-design.md` |
| **下游消费者** | `storyboard`（最直接的消费者——分镜必须执行这里的所有设计）、`story-review` |
| **完成后更新** | 写入 `production/session-state.md` |

**`ep{N}-design.md` 包含的字段：**

```
- 本话元信息
  - 话数、暂定标题
  - 所属幕
  - 前一话结束状态（优先取自前一话 storyboard 的结束状态摘要；
    若不存在，取自 ep{N-1}-design.md 的计划结束状态）
  - 本话结束状态
  - 下一话预期

- 页面预算  ← [新增]
  - 单话目标页数（继承自 comic-concept.md）
  - 本话实际分配页数
  - 容差检查：实际页数是否在目标 ±2 页范围内
  - 如超出容差：说明原因 + 调整方案

- 本话核心任务清单（从 story-structure 提取+细化）
  - ☐ 主线任务（必须完成）
  - ☐ 支线任务（如有）
  - ☐ 角色弧线推进任务
  - ☐ 伏笔埋设/回收任务（含完整伏笔上下文）  ← [增强]
    每条伏笔任务包含从 story-structure.md 伏笔网络复制的完整条目：
    | 伏笔名 | 本话操作(埋设/回收) | 埋设时的伪装 | 回收话 | 回收时的真相 | 视觉呈现方式 |
  - ☐ 信息揭示任务（从信息揭示时间表提取）
  - ☐ 主题论证任务（从主题论证追踪提取：本话在主题论证中扮演什么角色）  ← [新增]

- 叙述策略
  - 视角：跟谁？读者知道的比角色多还是少？
  - 时间结构：线性/插叙/倒叙/平行
  - 信息控制：本话读者应该知道什么、不应该知道什么
  - 悬念管理：本话要解答的旧悬念 + 要抛出的新悬念

- 场景列表（按顺序）
  | 序号 | 场景名 | 地点 | 出场角色 | 场景目的 | 预估页数 |
  - 页数合计行（与页面预算交叉校验）  ← [新增]

- 情绪地图
  - 逐页张力等级表
    | 页 | 目标情绪 | 张力(1-10) | 实现手段 |
  - ASCII 张力曲线图

- 爽点设计
  | 位置(页) | 类型 | 描述 | 视觉实现方式 |

- 笑点/轻松点设计
  | 位置(页) | 类型 | 描述 | 注意事项 |

- 钩子设计
  | 类型 | 位置 | 内容 | 目标效果 |
  - 话尾大钩子（必须有）
  - 中段微钩子（可选）
  - 翻页钩子（利用日式左翻的翻页机制）

- 分镜执行备注（给 storyboard 的约束指令）
  - 特殊构图要求
  - 特殊镜头要求
  - 伏笔的视觉呈现方式（从伏笔任务中提取）
  - 翻页利用点
```

**修改模式行为：**

```
当 ep{N}-design.md 已存在且用户要求修改时：
1. 读取现有文件，定位修改目标
2. 完成修改后，输出「变更影响清单」：
   - 若修改了场景列表/情绪地图/爽点/钩子位置
     → 标记本话的 storyboard（script + table + panel-prompts）需重做或局部修改
   - 若修改了本话结束状态
     → 标记下一话 ep{N+1}-design.md 的"前一话结束状态"需更新
   - 若修改导致页数预算变化
     → 重新执行页面预算校验
3. 更新 session-state.md
```

---

### 8. `storyboard`

| | 内容 |
|---|---|
| **职责** | 逐页逐格分镜脚本 + AI 画图提示词生成 |
| **依赖的文件** | ① `design/story/ep{N}-design.md`（最核心输入）② `design/style-guide.md` ③ `prompts/character-prompts.md` ④ `prompts/scene-prompts.md` ⑤ `design/world/worldbook.md`（场景视觉参考）⑥ 本话涉及角色的 `design/characters/*.md`（表情变体、服装状态、语言画像） |
| **依赖的 skill 产出** | `episode-design`（情绪地图→决定每页镜头节奏；爽点/笑点/钩子位置→决定哪些格要特殊处理；场景列表→决定页的分配；分镜执行备注→直接约束构图；伏笔完整上下文→决定伪装的精确程度）+ `style-guide`（全局提示词前缀 + 分格规范）+ `design-character`（角色外貌锚定词——拼装到每格提示词中；语言画像——对白风格依据）+ `design-world`（场景锚定词——拼装到每格提示词中） |
| **自身产出文件** | ① `storyboard/ep{N}/ep{N}-script.md` ② `storyboard/ep{N}/ep{N}-table.md` ③ `prompts/ep{N}-panel-prompts.md` |
| **下游消费者** | `story-review`、下一话的 `episode-design`（通过结束状态摘要） |
| **完成后更新** | 写入 `production/session-state.md` |

**`ep{N}-script.md` 的字段（叙述版）：**

```
每页 → 每格：
  - 格编号
  - 格形状与位置描述
  - 镜头类型
  - 画面内容描述（中文）
  - 对白/旁白/音效

---

## 本话结束状态摘要  ← [新增，位于文件末尾]

- 最后一格画面描述
- 主角当前物理位置
- 主角当前心理/情绪状态
- 各在场角色的状态
- 读者此时掌握的信息清单（对比本话开始时新增了什么）
- 本话末尾的悬念/钩子内容
- 下一话衔接点
```

**`ep{N}-table.md` 的字段（表格版）：**

```
| 页 | 格 | 格形状 | 占比 | 镜头 | 画面描述 | 对白/旁白/音效 | 情绪 | AI提示词(EN) | 提示词翻译(CN) |
```

**`ep{N}-panel-prompts.md` 的字段：**

```
每格一条，格式为：
## P{页}-G{格}
[完整提示词] = style-guide前缀 + 角色锚定词 + 场景锚定词 + 本格特有描述
（中文翻译）
```

---

### 9. `story-review`

| | 内容 |
|---|---|
| **职责** | 交叉验证所有文档的一致性 |
| **依赖的文件** | 几乎所有文件——它需要交叉比对 |
| **依赖的 skill 产出** | 全部上游 skill（它读取所有产出，不产出创作内容，只产出审查报告） |
| **自身产出文件** | `reviews/ep{N}-review.md` 或 `reviews/{检查类型}-review.md` |
| **下游消费者** | 用户根据审查结果回到对应 skill 修改；`gate-check` 会检查 review 是否通过 |
| **完成后更新** | 写入 `production/session-state.md` |

**`review.md` 包含的字段：**

```
- 审查范围（审查了哪些文件）

- 角色行为一致性检查
  | 话:页:格 | 角色 | 行为 | 预期反应(据角色卡) | 是否一致 | 问题 |

- 角色语言一致性检查  ← [新增]
  | 话:页:格 | 角色 | 台词 | 语言画像匹配度 | 问题 |

- 世界规则一致性检查
  | 话:页:格 | 涉及规则 | 是否违反 | 问题 |

- 伏笔检查
  | 伏笔名 | 应埋设位置 | 实际是否出现 | 应回收位置 | 实际是否回收 |

- 信息揭示检查
  | 信息 | 计划揭示话 | 实际揭示话 | 是否一致 |

- 主题论证检查  ← [新增]
  | 计划阶段 | 计划话 | 实际体现位置 | 是否有效传达 | 问题 |

- 情绪节奏检查
  - 实际张力曲线 vs episode-design 的目标张力曲线

- 页面预算检查  ← [新增]
  - 本话实际页数 vs episode-design 的预算
  - 如超出：超出原因分析

- 遗漏检查
  - episode-design 中标记的核心任务，是否全部在分镜中体现

- 总结
  - 发现的问题列表（按严重性排序）
  - 建议修改项
  - 建议重新执行的 skill 列表  ← [新增]
    | 问题 | 应回到的 skill | 修改目标 | 优先级 |
  - 判定：通过 / 需修改 / 需重大修改
```

---

### 10. `gate-check`

| | 内容 |
|---|---|
| **职责** | 阶段门禁验证 + 时序一致性检查 |
| **依赖的文件** | 取决于检查哪个门禁（见下方） |
| **依赖的 skill 产出** | 取决于门禁阶段 |
| **自身产出文件** | `production/gate-checks/{门禁名}.md` |
| **下游消费者** | 用户决策（是否推进到下一阶段） |
| **完成后更新** | 写入 `production/session-state.md` |

**门禁定义：**

| 门禁 | 检查项 | 需存在的文件 |
|------|--------|-------------|
| 企划→世界观 | 企划书完整，含单话目标页数 | `comic-concept.md` |
| 世界观→角色 | 世界观规则完备、场景列表完整 | `worldbook.md` + `scene-prompts.md` |
| 角色→故事结构 | 核心角色全部设计完、关系网络建立 | `character-index.md` + 各角色卡 + `character-prompts.md` |
| 故事结构→分话设计 | 总弧线确定、分话大纲确定、追踪系统建立 | `story-structure.md`（含主题论证追踪）+ `episode-index.md` |
| 分话设计→分镜 | 当前话的 episode-design 完整，页面预算通过 | `ep{N}-design.md`（所有字段已填，页面预算校验通过） |
| 分镜→完成 | 分镜脚本完整 + 结束状态摘要存在 + review 通过 | `ep{N}-script.md`（含结束状态摘要）+ `ep{N}-table.md` + `ep{N}-panel-prompts.md` + review 判定通过 |

**时序一致性检查（所有门禁通用）：**  ← [新增]

```
在每次门禁检查时，额外执行以下检查：

1. 获取所有相关文件的最后修改时间
2. 按依赖关系，检查上游文件是否比下游文件更新
   - 若 comic-concept.md 比 worldbook.md 更新
     → 警告："企划书在世界观之后被修改过，worldbook.md 可能需要同步更新"
   - 若角色卡比 story-structure.md 更新
     → 警告："角色设计在故事结构之后被修改过，角色弧线追踪可能需要同步更新"
   - 若 ep{N}-design.md 比 ep{N}-script.md 更新
     → 警告："单话设计在分镜之后被修改过，分镜可能需要重做"
   - ...以此类推
3. 输出时序警告列表（如有）
4. 如存在时序警告，门禁判定为"条件通过"（文件齐备但可能过时），
   建议用户先处理时序警告再推进
```

---

### 11. `session-state.md` 定义  ← [新增，完整定义]

| | 内容 |
|---|---|
| **职责** | 记录项目的实时工作状态，供 `start-comic` 快速恢复上下文 |
| **写入者** | 所有 skill 在完成操作后写入 |
| **读取者** | `start-comic`（启动时读取，快速判断上次中断点） |
| **文件路径** | `production/session-state.md` |

**`session-state.md` 包含的字段：**

```
- 项目名称
- 当前阶段（企划/世界观/角色设计/故事结构/分话设计/分镜/审查）
- 最后操作
  - 执行的 skill 名
  - 操作时间
  - 操作内容摘要（如："完成了 ep03-design.md 的初稿"）
  - 操作结果（成功/中断/需要用户输入）
- 中断点（如有）
  - 中断位置描述（如："ep03-design 的情绪地图设计进行到第12页"）
  - 恢复时需要的上下文
- 文件状态快照
  | 文件 | 状态 | 最后修改 | 备注 |
  | comic-concept.md | 完成 | 2025-01-15 | — |
  | worldbook.md | 完成 | 2025-01-16 | — |
  | ep03-design.md | 进行中 | 2025-01-20 | 情绪地图未完成 |
  | ... | | | |
- 待处理事项
  - 来自 story-review 的未解决问题
  - 来自 gate-check 的时序警告
  - 来自修改模式的未同步下游文件
- 下一步建议（由最后执行的 skill 写入）
```

---

## 依赖关系全景图

```
                        start-comic
                          │ (读取 session-state.md + 扫描目录)
                          │ (内置 project-detect 的全部诊断逻辑)
                          │
                          ▼
                      brainstorm
                     ┌────┤ comic-concept.md
                     │    │
          ┌──────────┼────┤
          ▼          ▼    ▼
    design-world   style-guide
    ┌─┤ worldbook.md    │ style-guide.md
    │ │ scene-prompts   │
    │ │    │            │
    │ │    └──►style-guide（也读取 worldbook）
    │ │                 │
    │ ▼                 │
    │ design-character  │
    │ ┌─┤ character-index.md
    │ │ │ {name}.md (×N)
    │ │ │ character-prompts.md
    │ │ │
    │ │ ▼
    │ │ plot-architecture
    │ │ ┌─┤ story-structure.md（含主题论证追踪）
    │ │ │ │ episode-index.md
    │ │ │ │
    │ │ │ ▼
    │ │ │ episode-design (逐话循环)
    │ │ │ ┌─┤ ep{N}-design.md（含完整伏笔上下文、页面预算）
    │ │ │ │ │              ↑ 读取前一话 storyboard 的结束状态摘要
    │ │ │ │ │
    ▼ ▼ ▼ ▼ ▼
    storyboard (逐话循环)
    ┌─┤ ep{N}-script.md（含本话结束状态摘要）
    │ │ ep{N}-table.md
    │ │ ep{N}-panel-prompts.md
    │ │
    ▼ ▼
    story-review ◄── 读取所有上游文件做交叉验证
    │ ep{N}-review.md（含建议重新执行的 skill 列表）
    │
    ▼
    gate-check ◄── 检查文件齐备 + review 是否通过 + 时序一致性
    │
    ▼
    session-state.md ◄── 所有 skill 完成后写入
```

**每个 skill 的输入来源汇总表：**

| Skill | brainstorm | design-world | design-character | style-guide | plot-architecture | episode-design | storyboard |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| design-world | ✅ | — | — | — | — | — | — |
| design-character | ✅ | ✅ | — | — | — | — | — |
| style-guide | ✅ | ✅ | — | — | — | — | — |
| plot-architecture | ✅ | ✅ | ✅ | — | — | — | — |
| episode-design | ⚪ 可选 | ✅ | ✅ | — | ✅ | ✅ 前一话 | ✅ 前一话摘要 |
| storyboard | — | ✅ | ✅ | ✅ | — | ✅ 本话 | — |
| story-review | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| gate-check | 检查存在性+时序 | 检查存在性+时序 | 检查存在性+时序 | 检查存在性+时序 | 检查存在性+时序 | 检查存在性+时序 | 检查存在性+时序 |

> ✅ = 必须读取　⚪ = 可选参照　— = 不读取

---

## 变更传播机制总览  ← [新增章节]

当任一上游文件被修改时，修改传播的路径如下：

```
comic-concept.md 被修改
  → 影响：worldbook.md, 所有角色卡, style-guide.md, story-structure.md
  → 传播深度：可能波及全部下游

worldbook.md 被修改
  → 影响：scene-prompts.md, 角色卡中"与世界规则的交互", story-structure.md
  → 传播深度：可能波及 episode-design 及以下

某角色卡被修改
  → 影响：character-index.md, character-prompts.md, story-structure.md 角色弧线,
          该角色出场话的 ep{N}-design.md 和 storyboard
  → 传播深度：仅影响该角色涉及的话

story-structure.md 被修改
  → 影响：episode-index.md, 涉及话的 ep{N}-design.md
  → 传播深度：可能波及多话的 episode-design 及 storyboard

ep{N}-design.md 被修改
  → 影响：本话的 storyboard, 下一话的 ep{N+1}-design.md（结束状态衔接）
  → 传播深度：通常限于本话和下一话
```

**每个可回溯修改的 skill 在修改模式下必须执行的标准流程：**

```
1. 读取现有文件，展示当前内容
2. 与用户确认修改范围
3. 执行修改
4. 输出「变更影响清单」（列出受影响的下游文件 + 建议操作）
5. 同步更新直接关联的产出文件（如 index、prompts）
6. 更新 session-state.md（在"待处理事项"中登记未同步的下游文件）
```
```