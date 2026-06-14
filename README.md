# cocowork-tools

**Claude + Codex 双 Agent 协作 CLI 工具链**

CLI toolchain for dual-agent (Claude + Codex) collaboration via AgentBridge.

---

## 概述 / Overview

在这套协作流程中，**Claude** 负责计划、整合、代码修改和最终决策，**Codex** 负责独立审查、测试验证和风险分析。这套工具让你在任何项目目录一键启动双 Agent 环境，并在项目本地维护跨 session 的共享记忆，避免每次重启后丢失上下文。

In this workflow, **Claude** owns planning, synthesis, code edits, and final decisions. **Codex** owns independent review, testing, verification, and risk analysis. These tools let you launch a dual-agent environment in any project directory with one command, and maintain cross-session shared memory locally per project.

---

## 安装 / Install

```bash
git clone https://github.com/Nyarlathoteppppp/cocowork-tools.git
cd cocowork-tools
chmod +x install.sh
./install.sh
```

默认安装到 `/opt/homebrew/bin/`。可通过环境变量自定义路径：

```bash
INSTALL_DIR=/usr/local/bin ./install.sh
```

### 依赖 / Requirements

- **macOS** — 依赖 `osascript` 启动 Terminal 窗口
- **[AgentBridge](https://agentbridge.dev)** — Claude 和 Codex 之间的通信层
- **Claude Code CLI** 和 **Codex CLI** — 已安装并可用
- **zsh** — macOS 默认 shell

---

## 工具一览 / Tool Overview

| 命令 | 英文描述 | 中文说明 |
|---|---|---|
| `abg-open` | Launch dual-agent collaboration in any project | 在任意项目中启动双 Agent 协作环境 |
| `abg-upgrade` | Check and upgrade framework version | 检查并升级协作框架版本 |
| `abg-remember` | Write a memory entry from CLI | 从命令行写入一条记忆条目 |
| `abg-recall` | Search memory entries | 搜索记忆条目 |

所有命令都支持 `--help` 查看详细用法。

---

## `abg-open` — 启动协作环境

在任意项目目录启动 Claude + Codex 协作，自动完成初始化。这是最核心的命令。

### 基础用法

```bash
# 在当前 workspace 启动
abg-open

# 在指定项目目录启动
abg-open /path/to/my-project

# 传入文件则使用其父目录
abg-open package.json

# 首次启动前预览（不会打开窗口）
abg-open . --dry-run
```

### 恢复 session

```bash
# 恢复上一次 Claude session 和当前 Codex thread
abg-open . --resume

# 恢复并同时打开日志窗口
abg-open . --resume --logs
```

### 常用组合

```bash
# 完整启动：恢复 session + 日志 + 诊断
abg-open . --resume --logs --doctor

# 排查模式：先杀残留再启动
abg-open . --kill-stale --doctor --logs

# 安全模式：Codex 只读
abg-open . --codex-read-only

# 完全信任模式：Codex 完全访问 + Claude 免确认
abg-open . --codex-full-access --claude-permission-mode bypassPermissions
```

### 高级选项

| 选项 | 作用 |
|---|---|
| `--resume` | 恢复上一次 Claude session 和当前 Codex thread |
| `--dry-run` | 只做 onboarding / scaffold，不启动 Terminal 窗口 |
| `--no-init` | 跳过初始化（项目已有配置时使用） |
| `--logs` | 额外打开一个 Terminal 标签页显示 `abg logs -f` |
| `--doctor` | 启动前运行 `abg doctor` 诊断 |
| `--kill-stale` | 启动前杀掉该 pair 的残留进程 |
| `--pair NAME` | 指定 pair 名称（默认 `main`），用于隔离不同的协作线 |
| `--model MODEL` | 指定 Claude 模型 |
| `--pro` | 等价于 `--model deepseek-v4-pro` |
| `--flash` | 等价于 `--model deepseek-v4-flash` |
| `--new-codex` | 启动一个新的 Codex thread |
| `--codex-read-only` | Codex 只读（不能修改文件） |
| `--codex-workspace-write` | Codex 可写 workspace 文件 |
| `--codex-full-access` | Codex 完全访问权限 |
| `--codex-approval POLICY` | Codex 审批策略 |
| `--claude-permission-mode MODE` | Claude 权限模式 |
| `--unsafe` | 不使用 `--safe` 模式 |
| `-h, --help` | 显示帮助信息 |

### 第一次运行会发生什么

首次在项目中运行 `abg-open .` 或带 `--dry-run` 时，自动执行以下步骤：

1. **AgentBridge 初始化** — 创建 `.agentbridge/config.json`
2. **版本追踪** — 创建 `.agentbridge/framework.json`，记录框架和模板版本
3. **Memory 目录 scaffold** — 创建 `memory/` 目录树，包含 `claude/`、`codex/`、`shared/` 子目录和 stub 文件
4. **协作协议注入** — 在 `CLAUDE.md` 和 `AGENTS.md` 中注入 `<!-- AgentBridge:start -->` 标记块

如果文件已存在，不会覆盖已有内容：
- `CLAUDE.md` / `AGENTS.md` 已有 `AgentBridge` 标记块 → 跳过
- 文件已存在但没有标记块 → 在末尾追加
- 标记块损坏（只有开始没有结束） → 跳过并警告
- 可通过 `ABG_AUTO_ONBOARD=0` 或 `--no-init` 完全跳过初始化

---

## `abg-upgrade` — 版本升级与检查

当协作协议更新时（如角色分工调整、Request-ID 规则变化、记忆读写规则改变），`abg-open` 启动时会自动检测到版本漂移并提示升级。

### 用法

```bash
# 检查版本状态
abg-upgrade --check

# 预览升级改动（推荐先执行）
abg-upgrade --dry-run

# 执行升级
abg-upgrade

# 升级到指定项目
abg-upgrade /path/to/my-project

# 版本匹配也强制重写
abg-upgrade --force
```

### 退出码

| 退出码 | 含义 |
|---|---|
| 0 | 版本已最新 / 升级完成 |
| 1 | 需要升级（在 `--check` 模式下） |
| 2 | 参数错误 |
| 3 | 项目未启用 cowork 框架 |

### 升级过程

1. **备份** — 将 `CLAUDE.md` 和 `AGENTS.md` 复制到 `.agentbridge/backups/`
2. **替换标记块** — 仅替换 `<!-- AgentBridge:start -->` 和 `<!-- AgentBridge:end -->` 之间的内容，外部内容原样保留
3. **原子写入** — 写临时文件然后 `mv`，崩溃不会损坏原文件
4. **更新元数据** — 更新 `framework.json` 中的版本号和 `last_upgraded_at`

升级时如果检测到多个标记块、标记块损坏或文件缺失，会跳过该文件并警告，不会阻止其他文件的升级。

---

## `abg-remember` — 写入记忆条目

快速向当前项目的共享记忆中添加一条记录，自动生成 YAML frontmatter、文件名和 Markdown 正文。

### 用法

```bash
# 最简单的写法（默认 type=note, priority=normal, visibility=shared）
abg-remember "修复了登录页的 CSRF 问题"

# 完整参数
abg-remember "不要用当前分钟的 CronCreate" \
  --type gotcha \
  --priority critical \
  --visibility shared \
  --summary "One-shot CronCreate 依赖分钟级 cron，设置时间小于 120 秒可能被错过或在很远的未来才触发" \
  --details "具体来说，当 Claude 想在 20 秒后通过 CronCreate 唤醒自己检查 Codex 回复时，由于 cron 只精确到分钟，这个定时可能被安排在下一分钟甚至更晚。应该用快速轮询 + 至少 120 秒后的 CronCreate 方案。" \
  --tags "agentbridge, cron, polling"

# 决策记录
abg-remember "使用 SQLite 做本地存储" \
  --type decision --priority high \
  --tags "db, local-storage"

# Claude 私有笔记
abg-remember "Codex 对 Rust 不太熟悉，需要给更多上下文" \
  --type note --visibility claude

# 编码约定
abg-remember "API 路由命名使用 kebab-case" \
  --type convention --priority high --visibility shared
```

### 参数

| 参数 | 说明 | 可选值 | 默认值 |
|---|---|---|---|
| `title` | 条目标题（必填，第一位置参数） | — | — |
| `--type` | 条目类型 | `decision`, `gotcha`, `convention`, `verification`, `handoff`, `note` | `note` |
| `--priority` | 优先级 | `critical`, `high`, `normal`, `low` | `normal` |
| `--visibility` | 可见范围 | `shared`, `claude`, `codex` | `shared` |
| `--agent` | 作者 | `claude`, `codex`, `user`, `shared` | 匹配 visibility |
| `--summary` | 一句话摘要 | 任意文本 | 同 title |
| `--details` | 详细描述 | 任意文本 | 同 title |
| `--tags` | 逗号分隔标签 | 如 `"db, api, rust"` | 空 |
| `--workspace PATH` | 指定项目路径 | 任意目录 | 当前目录 |

### 文件生成规则

```
memory/<visibility>/<type_plural>/<文件名>.md
```

类型到目录名的映射：

| 类型 | 目录名 |
|---|---|
| `decision` | `decisions/` |
| `gotcha` | `gotchas/` |
| `convention` | `conventions/` |
| `verification` | `verifications/` |
| `handoff` | `handoffs/` |
| `note` | `notes/` |

文件名格式：`YYYYMMDD-HHMMSS-<agent>-<type>-<slug>.md`

例如：
```
memory/shared/gotchas/20260614-143000-shared-gotcha-no-current-minute-cron.md
```

如果同一秒内生成重复文件名，会自动追加 `-a1`、`-a2` 后缀。中文标题自动转为 ASCII slug，如果为空则使用 `memory-entry`。

生成的 frontmatter（示例）：

```yaml
---
schema_version: 1
id: 20260614-143000-shared-gotcha-no-current-minute-cron
title: 不要用当前分钟的 CronCreate
type: gotcha
status: active
priority: critical
visibility: shared
scope: project
project: my-project
agent: shared
created: 2026-06-14T14:30:00+0800
updated: 2026-06-14T14:30:00+0800
tags: [agentbridge, cron, polling]
supersedes: null
related: []
---
```

---

## `abg-recall` — 搜索记忆条目

搜索当前项目共享记忆中的条目，支持全文搜索和多种筛选条件。

### 用法

```bash
# 基本搜索
abg-recall "cron"
abg-recall "SQLite"

# 按类型筛选
abg-recall --type gotcha
abg-recall --type decision

# 按优先级筛选
abg-recall --priority critical

# 按标签筛选
abg-recall --tag database

# 按作者筛选
abg-recall --agent claude

# 按 ID 精确查找
abg-recall --id 20260614-123456-shared-gotcha

# 组合筛选
abg-recall --type gotcha --priority critical --tag agentbridge

# 控制输出数量
abg-recall --type gotcha --limit 5
abg-recall --all

# 包含已废弃的条目（默认只显示 active）
abg-recall --include-stale
```

### 参数

| 参数 | 说明 | 默认值 |
|---|---|---|
| `search-term` | 搜索关键词（匹配标题和摘要） | — |
| `--type TYPE` | 按类型筛选 | 全部 |
| `--priority PRIO` | 按优先级筛选 | 全部 |
| `--tag TAG` | 按标签筛选 | 全部 |
| `--agent AGENT` | 按作者筛选 | 全部 |
| `--id ID` | 按 ID 查找（支持部分匹配） | 全部 |
| `--limit N` | 最大结果数 | 10 |
| `--all` | 不限结果数 | — |
| `--include-stale` | 包含已废弃（stale/superseded）条目 | 仅 active |
| `--workspace PATH` | 指定项目路径 | 当前目录 |

### 搜索范围

搜索关键词会匹配：
- 条目标题（`title` 字段）
- 摘要（`## Summary` 段落）
- 条目 ID（`id` 字段）

不搜索详情（`## Details`），保持查询速度。

### 排序规则

1. 优先级升序：critical → high → normal → low
2. 时间倒序：最新的优先

### 输出格式

```
1. Do not schedule current-minute one-shot CronCreate
   id: 20260614-123456-shared-gotcha-no-current-minute-cron
   type: gotcha | priority: critical
   path: memory/shared/gotchas/20260614-123456-shared-gotcha-no-current-minute-cron.md
   summary: One-shot CronCreate uses minute-level cron...

2. Use SQLite for local storage
   id: 20260614-123457-shared-decision-sqlite-local-storage
   type: decision | priority: high
   path: memory/shared/decisions/20260614-123457-shared-decision-sqlite-local-storage.md
   summary: Store local data in SQLite
```

如果没有匹配结果，输出 "No matches" 并以退出码 0 返回。

---

## Memory 系统详解

每个启用协作的项目都在本地维护 `memory/` 目录，用于持久化双 Agent 的跨 session 共享记忆。

### 目录结构

```
memory/
├── claude/                 # Claude 专属条目（Codex 只读）
│   ├── decisions/
│   ├── conventions/
│   ├── handoffs/
│   ├── notes/
│   └── verifications/
├── codex/                  # Codex 专属条目（Claude 只读）
│   ├── findings/
│   ├── handoffs/
│   ├── notes/
│   └── verifications/
├── shared/                 # 共享/约定条目（双方可读写）
│   ├── decisions/          # 架构和技术决策
│   ├── gotchas/            # 踩过的坑和避免方法
│   ├── conventions/        # 编码/流程约定
│   ├── handoffs/           # 交接记录
│   └── ...                 # 按类型自动创建子目录
├── MEMORY.md               # 非权威索引（方便人类阅读）
├── resume.md               # abg-open --resume 自动生成的启动摘要
└── README.md               # 完整协议和 schema 说明
```

### 写入规则

- 不要直接编辑另一个 Agent 的条目。如果有不同意见，新建一条并用 `supersedes` 或 `related` 链接
- 共享条目需要双方同意或用户确认
- 使用原子写入（temp + mv），避免并发写导致文件损坏
- 标记为 `status: stale` 或 `status: superseded` 的条目不会出现在默认搜索结果中
- 格式错误的条目被跳过并警告，不会影响工具运行

---

## 版本管理

每个项目的 `.agentbridge/framework.json` 记录版本信息：

```json
{
  "framework": "agentbridge-cowork",
  "framework_version": "1.0.0",
  "template_version": "1.0.0",
  "memory_schema_version": 1,
  "installed_at": "2026-06-14T12:00:00+0800",
  "last_upgraded_at": "2026-06-14T12:00:00+0800"
}
```

| 字段 | 说明 |
|---|---|
| `framework_version` | 工具链版本 |
| `template_version` | CLAUDE/AGENTS 标记块模板版本 |
| `memory_schema_version` | 记忆条目 schema 版本 |

`abg-open` 启动时自动对比项目版本和当前版本，如果不一致会打印提示：

```
[abg-open] Cowork framework upgrade available: project template=0.9.0, current=1.0.0
Run `abg-upgrade --dry-run` to preview changes
```

---

## 完整工作流示例

```bash
# ===== 日常使用 =====

# 1. 进入你的项目
cd my-real-project

# 2. 首次启动（自动初始化）
abg-open .

# 3. 项目中做了一个技术决策，记下来
abg-remember "API 响应缓存策略" \
  --type decision --priority high \
  --summary "使用 Redis 缓存热点 API，TTL 5 分钟" \
  --details "对 /api/products 和 /api/users 两个热点接口启用 Redis 缓存，缓存 5 分钟。缓存穿透时从数据库回源。" \
  --tags "api, performance, redis"

# 4. 踩了个坑，赶紧记下来
abg-remember "文件上传路径拼接不要用字符串" \
  --type gotcha --priority critical \
  --summary "用 Path.join 而不是字符串拼接，否则跨平台路径有问题" \
  --tags "file-upload, security"

# 5. 第二天回来，恢复之前的 session
abg-open . --resume --logs

# 6. 搜一下关于缓存的决策
abg-recall "缓存" --type decision

# 7. 搜一下关于安全的坑
abg-recall --tag security --priority critical

# ===== 版本管理 =====

# 检查版本
abg-upgrade --check

# 预览升级
abg-upgrade --dry-run

# 执行升级
abg-upgrade

# ===== 多 pair 协作 =====

# 主开发线
abg-open . --pair main

# 同时进行代码审查
abg-open . --pair review --codex-read-only

# 探索新方案
abg-open . --pair experiment --new-codex
```

---

## 项目结构

```
cocowork-tools/
├── bin/
│   ├── abg-open          # 启动协作环境
│   ├── abg-upgrade       # 版本检查与升级
│   ├── abg-remember      # 写入记忆
│   └── abg-recall        # 搜索记忆
├── install.sh            # 安装脚本
└── README.md             # 本文件
```

---

## 与 `cocowrok` 仓库的关系

- **[cocowork-tools](https://github.com/Nyarlathoteppppp/cocowork-tools)** — 本仓库，CLI 工具链
- **[cocowrok](https://github.com/Nyarlathoteppppp/cocowrok)** — 默认 workspace 配置、共享记忆数据和协作协议文档

两个仓库独立。工具链是可分发的，workspace 是个人化的。

---

## 许可证 / License

MIT
