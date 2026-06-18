# Motion Breakdown Board Generator 中文说明

English version: [README.en.md](./README.en.md)

这是一个 Codex Skill，用来把一张静态图片拆解成专业的 `动效运动说明图 / motion breakdown board`，并在需要时把说明图继续交给 Dreamina CLI（即梦）生成视频。

它不是视频渲染器，也不是普通海报生成器。它的首要目标，是输出一张清晰、专业、可执行的静态动效说明图。

## 功能概览

- 分析上传图片中的主体、风格、可运动元素和锁定元素
- 默认设计 `8 秒固定镜头无缝循环` 的动效方案
- 将动效拆成 `6 到 8 个关键阶段`
- 输出简洁的动效设计说明
- 生成静态 `motion breakdown board`
- 在需要时生成更适合视频提交的 `clean handoff board`
- 只有在用户确认自己是 `高级即梦会员` 之后，才继续进入 Dreamina CLI 视频流程

## 适用场景

当用户上传图片，并提出类似请求时，适合使用本 Skill：

- 给这张图设计动效
- 生成动效运动说明图
- 做一张 `motion breakdown board`
- 设计一个 8 秒循环动画方案
- 基于这张图做无缝循环动效
- 先出说明图，再接即梦生成视频

## 默认行为

如果用户没有额外说明，Skill 默认使用：

- `8 秒`
- `固定镜头`
- `无缝循环`
- `主体造型保持不变`
- `不新增复杂场景`
- `动作逐步递进`
- `最后一帧自然回到第一帧`

如果用户一开始就明确说明了想要的循环类型、时长、镜头、动作风格或节奏，Skill 优先采用用户要求，默认值只用于补空白。

## 工作流

### 1. 图片理解

Skill 会先分析：

- 主体是什么
- 视觉风格是什么
- 主色调是什么
- 哪些元素适合运动
- 哪些元素必须锁定不变
- 更适合哪类动效关键词

### 2. 动效设计

Skill 会基于图像内容设计一个闭环动效逻辑，通常组织成：

- 起始
- 预备
- 展开
- 峰值
- 回落
- 回弹
- 复位

### 3. 说明图输出

Skill 会优先输出一张静态专业说明图，而不是直接生成视频。说明图通常包含：

- 一个主参考图区
- 6 到 8 个阶段小图
- 箭头、轨迹线、残影或位移示意
- 时间标记
- 简短中文说明
- `0s -> 8s -> 0s` 的循环时间轴

这张图优先服务于人看懂动作逻辑。如果后续要接 Dreamina 视频生成，Skill 会尽量再准备一张更干净的 handoff 图，减少箭头、文字、时间轴等说明图元素。

### 4. Dreamina 视频分支

如果用户还想继续生成视频，Skill 会先问：

`如果继续生成视频，请先确认你是否是高级即梦会员？`

分支规则如下：

- 用户回答 `不是`：流程结束在说明图
- 用户回答 `不确定`：流程暂停，等待用户先核实账号
- 用户回答 `是`：直接进入 Dreamina CLI 视频流程，不再重复追问“要不要继续生成视频”

即使用户口头确认自己是高级即梦会员，也仍然要以 Dreamina CLI 实际返回的账号权限结果为准。

进入 Dreamina 流程后，Skill 优先采用：

- 图一 = 原始角色图
- 图二 = clean handoff board；如果没有，则使用说明图并配更强的负向约束提示词

Dreamina 提交提示词必须明确说明：图二只是 `动作说明`，不是最终画面风格；同时必须明确禁止箭头、数字、文字、边框、时间轴等说明图元素进入最终视频画面。

## 目录结构

```text
motion-breakdown-board-generator/
├── SKILL.md
├── README.md
├── README.en.md
├── LICENSE
├── agents/
│   └── openai.yaml
├── references/
│   ├── board-spec.md
│   └── dreamina-video-workflow.md
└── scripts/
    └── submit_dreamina_video.ps1
```

## 关键文件说明

- [SKILL.md](./SKILL.md)
  Skill 主指令文件，供 Codex 触发和执行。

- [references/board-spec.md](./references/board-spec.md)
  说明图结构规范、提示词模板、板式规则。

- [references/dreamina-video-workflow.md](./references/dreamina-video-workflow.md)
  即梦视频生成分支的工作流说明。

- [scripts/submit_dreamina_video.ps1](./scripts/submit_dreamina_video.ps1)
  PowerShell 包装脚本，用于调用 Dreamina CLI 进行 `提交 -> 轮询 -> 下载`。

## 使用示例

### 仅生成说明图

```text
给这张图设计一个 8 秒无缝循环动效，并生成运动说明图。
```

### 用户指定动效方向

```text
给这张图做一个 5 秒轻盈漂浮感循环，镜头固定，重点让头发和衣摆有延迟摆动。
```

### 说明图后接即梦

```text
先生成 motion breakdown board。确认我是高级即梦会员后，再继续接即梦生成视频。
```

## 安装位置

如果你希望 Codex 自动发现这个 Skill，常见放置方式有两种：

- 用户级：`~/.codex/skills/motion-breakdown-board-generator/`
- 项目级：`<project>/.codex/skills/motion-breakdown-board-generator/`

当前这份 Skill 使用的是项目级结构。

## 注意事项

- 这个 Skill 的核心产物是 `静态动效说明图`
- Dreamina 视频生成是可选分支，不是默认主路径
- Dreamina CLI 分支默认要求用户确认自己是 `高级即梦会员`
- 如果 Dreamina CLI 返回权限不足，流程必须停止
- 如果 Dreamina 开始把箭头、数字、时间轴等说明图元素 literalize 到视频里，优先换用 clean handoff board，并叠加更强的负向提示词

## License

This project is licensed under the [MIT License](./LICENSE).
