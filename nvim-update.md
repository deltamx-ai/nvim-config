# Neovim 插件（Extras）推荐 — Angular / React / Electron

> 生成于 2026-09-01。所有建议基于**你机器上真实项目的依赖**与 LazyVim 当前版本实际提供的 extras，非通用清单。
> 配套文档：`nvim.md`（键位与冲突分析）。

---

## 〇、先说结论

| 优先级 | 动作 | 一句话理由 |
|---|---|---|
| 🔴 P0 | 开 `lang.typescript.oxc` | 2 个项目有 `.oxlintrc.json`，但 oxlint 现在完全没接进编辑器 |
| 🔴 P0 | 开 `formatting.prettier` | `capa-demo` 有 `.prettierrc`，现在存盘不会按它格式化 |
| 🔴 P0 | **关掉** `lang.typescript.tsgo` | 它当前**完全空转**，被 vtsls 静默覆盖（详见 §2） |
| 🟠 P1 | 开 `dap.core` | Electron 主进程/渲染进程断点调试，适配器已自动配好 |
| 🟠 P1 | 开 `test.core` + 手动加 `neotest-vitest` | 2 个 Angular 项目用 vitest，LazyVim **不自带** vitest 适配器 |
| 🟠 P1 | 开 `ui.treesitter-context` | JSX / Angular 模板嵌套深，需要粘顶上下文 |
| 🟠 P1 | 开 `editor.inc-rename` | 跨文件重命名组件时实时预览影响面 |
| 🟡 P2 | 见 §5 的 7 个提效项 | 按需 |
| ⛔ | **不要**开 `linting.eslint` | 你**没有任何项目**用 eslint |

---

## 一、现状盘点

### 1.1 你的真实技术栈（读 `package.json` 得出）

| 项目 | 框架 | 构建 | Lint | Format | Test |
|---|---|---|---|---|---|
| `~/cws-react` | React 19.2 + Tailwind 4.1 | Vite 8 | **oxlint 1.71** | — | — |
| `~/workspace/ai/molecraft` | **Electron 43** + React 19.2 + react-router 8 + Tailwind 4.3 | Vite 8 | **oxlint 1.75** | — | — |
| `~/workspace/ai/oneapp` | **Angular 22.1** | Vite 8 | — | — | **vitest 4.1** |
| `~/workspace/ai/capa-demo` | **Angular 22.1** | ng | — | **prettier 3.8** | **vitest 4.0** |

全部 TypeScript `~6.0.2`。

**关键结论：你的技术栈是 oxlint + prettier + vitest，不是 eslint + jest。** 很多网上的 LazyVim 前端配置指南会让你开 `linting/eslint`，对你是**纯负担**。

### 1.2 已启用的 7 个 extras

```
lang.angular            ✅ 对 Angular 22 有效
lang.json               ✅
lang.tailwind           ✅ 对 Tailwind 4 有效
lang.typescript         ✅ 核心
lang.typescript.vtsls   ✅ 实际生效的 TS 语言服务器
lang.typescript.tsgo    ⚠️ 空转，见 §2
util.project            ✅ <leader>fp 项目切换
```

### 1.3 缺失的命令行工具

| 工具 | 状态 | 影响 |
|---|---|---|
| `fd` | ✅ 已装 10.2.0 | — |
| `rg` | ✅ 已装 14.1.1 | — |
| `gh` | ❌ 未装 | `util.octo` / `util.gh` 无法用（当前未启用这两个 extra） |
| `ng` | ⚠️ 指向 `/mnt/c/.../scoop/apps/nodejs22/` | **是 Windows 的二进制**，从 WSL 调用跨系统边界，极慢 |

```bash
sudo apt-get install -y gh          # 仅在要用 octo 时
```

`ng` 建议一律走项目本地：`npx ng ...` 或 `pnpm ng ...`，避免走 Windows 的 node。

---

## 二、🔴 先修一个坑：`tsgo` 正在空转

你同时启用了 `lang.typescript.vtsls` 和 `lang.typescript.tsgo`。**这两个都是 TypeScript 语言服务器**。

好消息是**它们不会打架**，LazyVim 有互斥机制。坏消息是**你以为开了 tsgo，其实没有**。

`LazyVim/lua/lazyvim/plugins/extras/lang/typescript/init.lua`：

```lua
local extra = LazyVim.config.register_defaults("ts_lsp", {
  { name = "vtsls", extra = "lang.typescript.vtsls" },   -- 排在前面
  { name = "tsgo",  extra = "lang.typescript.tsgo"  },
})
```

`register_defaults` 按**列表顺序**取第一个你启用了的，命中即 `break`。vtsls 排第一 → **vtsls 胜出**。然后：

```lua
local lsp = extra.name or "vtsls"
local servers = { "tsserver", "ts_ls", "vtsls", "tsgo", lsp }
for _, server in ipairs(servers) do
  opts.servers[server].enabled = server == lsp   -- tsgo 被显式禁用
end
```

**佐证**：`~/.local/share/nvim/mason/packages/` 里只有 `vtsls`，没有 tsgo。

### 怎么选

`tsgo` 是 TypeScript 官方用 Go 重写的语言服务器（typescript-go），**快一个数量级**，对你 4 个 TS 6.0 项目（尤其 Angular 22 这种大工程）收益明显；代价是成熟度不如 vtsls，且**不支持部分重构类 code action**（如 vtsls 的 "Move to file"）。

**方案 A — 保守（推荐先这样）**：关掉 tsgo，消除困惑
```
:LazyExtras      # 取消勾选 lang.typescript.tsgo
```

**方案 B — 尝鲜**：保留两个 extra，用全局变量强制选 tsgo（全局变量优先级高于 extra 顺序）

在 `lua/config/options.lua` 加：
```lua
vim.g.lazyvim_ts_lsp = "tsgo"
```
不满意随时改回 `"vtsls"`，无需动 extras。

> 无论选哪个，**别让两个 extra 同时开着又不设 `vim.g.lazyvim_ts_lsp`** —— 那就是现在的状态，看起来开了 tsgo，实际跑的是 vtsls。

---

## 三、🔴 P0：立刻该开的两个

### 3.1 `lang.typescript.oxc` — 把 oxlint 接进编辑器

**理由（硬证据）**：`~/cws-react/.oxlintrc.json` 和 `~/workspace/ai/molecraft/.oxlintrc.json` 都存在，`package.json` 里也都有 `oxlint` 依赖。但你的 nvim **完全没有加载任何 lint 服务**——现在只有 vtsls 的类型错误，oxlint 的规则违规（unused vars、React hooks 依赖数组、a11y 等）在编辑器里**一个都看不到**，只有 `npm run lint` 时才暴露。

这个 extra 做两件事：
1. 注册 `oxlint` LSP，带 monorepo 感知的 root 探测（先找 `.git`，再从那里找 `.oxlintrc.json`）——对 `single-spa-mfe` 这种多包结构很关键
2. 把 `oxfmt` 接进 conform 作为 JS/TS/JSON 的格式化器，并**显式禁用 oxfmt 的 LSP** 避免和 conform 抢

```lua
oxlint = {
  root_dir = function(bufnr, on_dir)
    local git = vim.fs.root(bufnr, ".git")
    local markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }
    local root = git and vim.fs.root(git, markers) or vim.fs.root(bufnr, markers)
    if root then on_dir(root) end
  end,
  settings = { fixKind = "all" },   -- 支持 code action 自动修
},
oxfmt = { enabled = false },
```

⚠️ **注意**：它会给 JS/TS/JSON 挂上 `oxfmt` 格式化器。而 `capa-demo` 用 prettier。两者会冲突——解决办法见 §3.3。

### 3.2 `formatting.prettier` — capa-demo 需要

**理由**：`~/workspace/ai/capa-demo/.prettierrc` 存在，`devDependencies` 有 `prettier ^3.8.1`。现在存盘时 nvim 不会按这份配置格式化，你和队友的 diff 会不一致。

LazyVim 的 prettier extra 只在**检测到项目里有 prettier 配置文件时**才启用该 formatter，所以不会污染没有 prettier 的项目。

### 3.3 两个格式化器共存的处理

开了 oxc + prettier 之后，`capa-demo` 可能同时被 oxfmt 和 prettier 处理。建议在 `lua/plugins/formatting.lua` 里显式表态：

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 有 .prettierrc 的项目让 prettier 独占，否则用 oxfmt
      local prettier_fts = { "typescript", "typescriptreact", "javascript",
                             "javascriptreact", "json", "jsonc", "css", "html", "scss" }
      for _, ft in ipairs(prettier_fts) do
        opts.formatters_by_ft[ft] = { "prettier", "oxfmt", stop_after_first = true }
      end
    end,
  },
}
```

`stop_after_first = true` 让 conform 用第一个**可用**的：项目有 prettier 配置就用 prettier，没有就落到 oxfmt。一份配置通吃四个项目。

---

## 四、🟠 P1：Electron 与测试

### 4.1 `dap.core` — Electron 断点调试

**这是 Electron 开发最大的缺口。** 你现在只能 `console.log`。

`molecraft` 有 `dev:electron` / `build:electron` / `dist` 脚本，是标准的 Electron 双进程结构。开 `dap.core` 后，`lang.typescript` extra 会**自动**做完剩下的事：

```lua
-- typescript/init.lua 已有的逻辑
for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
  local pwaType = "pwa-" .. adapterType     -- 注册 pwa-node / pwa-chrome
  ...
end
vscode.type_to_filetypes["node"] = js_filetypes
-- 并且会自动 mason 安装 js-debug-adapter
```

关键点：**它会读取项目里的 `.vscode/launch.json`**（和 VSCode 共用一份），也可以完全不用配置文件。

> **本项目决定：不创建 `.vscode/launch.json`。** 该文件会进 git 仓库、影响协作者，且 nvim-dap 不强制依赖它。
> 需要调试时有两条不落地到仓库的路径：
>
> 1. **附加到已运行的进程** —— 用 `dap.configurations` 在 nvim 侧配 attach，Electron 以
>    `--remote-debugging-port=9222` 启动后附加渲染进程；
> 2. **临时配置** —— 在 `lua/plugins/dap.lua` 里写 `dap.configurations.typescript = {...}`，
>    只存在于你自己的 nvim 配置中，不进项目仓库。
>
> 适配器本身已就绪（实测已注册 `pwa-node` / `pwa-chrome` / `pwa-msedge` 及无前缀别名），
> 随时可用，不需要额外安装。

调试键位（`dap.core` 提供）：`<leader>db` 断点 / `<leader>dc` 继续 / `<leader>di` 步入 / `<leader>du` 开关 DAP UI。

> ⚠️ WSL 提醒：Electron 是 GUI 应用，在 WSL 里跑依赖 WSLg。若渲染进程窗口卡顿，考虑在 Windows 侧跑 Electron、WSL 侧只做编辑。

### 4.2 `test.core` + `neotest-vitest` — 必须手动补适配器

**LazyVim 的 `test/core` 自带的 `adapters = {}` 是空的**（我搜过整个 extras 目录，**没有任何 vitest 或 jest 适配器**）。只开 `test.core` 你会得到一个不认识任何测试的 neotest。

`oneapp`（有 `vitest.config.ts`）和 `capa-demo` 都用 vitest。新建 `lua/plugins/neotest.lua`：

```lua
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "marilari88/neotest-vitest" },
    opts = { adapters = { "neotest-vitest" } },
  },
}
```

之后：`<leader>tt` 跑当前文件 / `<leader>tr` 跑最近的测试 / `<leader>ts` 测试树 / `<leader>tS` 停止。

### 4.3 `ui.treesitter-context` — 粘顶上下文

JSX 和 Angular 模板嵌套很深。滚到一个 `<div>` 中间时，屏幕顶部固定显示它属于哪个组件/哪个 `map()` 回调。对 React 大组件文件收益最明显，几乎零成本。

### 4.4 `editor.inc-rename` — 重命名实时预览

React 组件、Angular service/component 类名往往跨十几个文件。`inc-rename` 让 `<leader>cr` 在你输入新名字时**实时高亮所有将被改动的位置**，回车前就能看到影响面。配合 vtsls 的 `updateImportsOnFileMove` 已开启，重构体验完整。

---

## 五、🟡 P2：提效项（按需选）

| Extra | 对你的具体价值 |
|---|---|
| `coding.mini-surround` | `ysat<div>` 一键用标签包裹 JSX/模板；改标签名 `cst`。写 JSX 高频 |
| `editor.refactoring` | 可视选中一段 JSX → 提取成子组件；提取 React hook。补 vtsls 缺的重构 |
| `util.mini-hipatterns` | Tailwind 4 的任意值 `bg-[#1a1a2e]` 直接显示色块；也认 `#RRGGBB` |
| `editor.illuminate` | 高亮光标下同名符号，读大组件时快速看清某个 prop 用在哪几处 |
| `editor.aerial` | 符号大纲侧栏，Angular component class 的方法列表 / React 组件树 |
| `editor.harpoon2` | monorepo 里在 4~5 个核心文件间秒切，比 picker 快。`single-spa-mfe` 场景适用 |
| `editor.mini-move` | `<A-j>/<A-k>` 移动选中行，调整 JSX 元素顺序 |
| `lang.git` | `.gitcommit` / rebase todo 的语法与补全 |
| `lang.markdown` | README / 文档编辑 + 预览 |
| `lang.yaml` | GitHub Actions、`pnpm-workspace.yaml`、Angular 的 CI 配置 |
| `lang.docker` | 若 Electron 打包或后端服务用 Docker |

**建议起手只开前 4 个**（mini-surround / refactoring / mini-hipatterns / illuminate），用一周再决定要不要加 aerial 和 harpoon2 —— 后两个改变工作流习惯，不适合一次全上。

---

## 六、⛔ 明确不推荐

| Extra | 为什么不 |
|---|---|
| `linting.eslint` | **你没有任何项目用 eslint**，四个 `package.json` 里零 eslint 依赖。开了只会白跑一个 LSP |
| `lang.typescript.biome` | 同上，没项目用 biome。biome 和 oxlint 是竞品，别混装 |
| `editor.telescope` / `editor.fzf` | 你已经在用 snacks.picker，功能重叠。换选择器要重学一整套键位，收益为负 |
| `editor.neo-tree` | 你已经在用 snacks explorer（`<leader>e`），同上 |
| `coding.nvim-cmp` | 你在用 blink.cmp（更快），换回 nvim-cmp 是倒退 |
| `lang.vue` / `lang.svelte` / `lang.astro` | 技术栈里没有 |
| `formatting.black` / `lang.python` 等 | 与前端无关 |
| `util.octo` / `util.gh` | 依赖 `gh` CLI，你没装。想用先 `sudo apt-get install gh` |
| `ui.mini-animate` / `ui.smear-cursor` | 纯视觉动画。**WSL + Windows Terminal 下会明显掉帧**，别开 |

---

## 七、执行步骤

### 第一步：改 extras

```
nvim
:LazyExtras
```

在列表里用 `x` 切换。**勾选**：

```
lang.typescript.oxc
formatting.prettier
dap.core
test.core
ui.treesitter-context
editor.inc-rename
coding.mini-surround
editor.refactoring
util.mini-hipatterns
editor.illuminate
```

**取消勾选**：

```
lang.typescript.tsgo        （见 §2，或改用方案 B）
```

### 第二步：补两个 LazyExtras 覆盖不到的配置

`lua/plugins/neotest.lua`（vitest 适配器）：
```lua
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "marilari88/neotest-vitest" },
    opts = { adapters = { "neotest-vitest" } },
  },
}
```

`lua/plugins/formatting.lua`（prettier / oxfmt 优先级）：
```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local fts = { "typescript", "typescriptreact", "javascript",
                    "javascriptreact", "json", "jsonc", "css", "html", "scss" }
      for _, ft in ipairs(fts) do
        opts.formatters_by_ft[ft] = { "prettier", "oxfmt", stop_after_first = true }
      end
    end,
  },
}
```

### 第三步：装缺的 CLI 工具 ✅ 已完成

```
fd  10.2.0   -> ~/.local/bin/fd  （软链到 /usr/bin/fdfind）
rg  14.1.1   -> /usr/bin/rg      （本就已装）
```

`gh` 仅在启用 `util.octo` / `util.gh` 时需要，当前两者均未启用。

### 第四步：验证

```
:Lazy sync          # 拉新插件
:Mason              # 确认 js-debug-adapter / oxfmt / prettier 已装
:LspInfo            # 在 .tsx 文件里应看到 vtsls + oxlint + tailwindcss
:checkhealth        # 整体体检
```

在 `~/cws-react` 打开一个 `.tsx`，故意写个未使用变量 —— 应该立刻看到 oxlint 的诊断。
在 `~/workspace/ai/oneapp` 打开一个 `.spec.ts`，按 `<leader>tt` —— 应该能跑起 vitest。

---

## 八、预期变化

| 指标 | 现在 | 之后 |
|---|---|---|
| 已启用 extras | 7 | 16（+10 −1） |
| 插件数 | 33 | 约 50 |
| 编辑器内可见的 lint | ❌ 无 | ✅ oxlint 全规则 |
| 存盘格式化 | 仅 stylua/shfmt | ✅ prettier / oxfmt 按项目自动选 |
| Electron 调试 | `console.log` | ✅ 主进程 + 渲染进程断点 |
| 跑测试 | 切终端 `npm test` | ✅ `<leader>tt` 就地跑 |

启动时间会增加，但 `dap.core`、`test.core`、`inc-rename` 都是懒加载（按键或命令触发），日常打开 `.tsx` 的冷启动影响很小。用 `util.startuptime` extra 可以量化，若在意再说。
