# Neovim 配置说明书

> 更新于 2026-09-01（第 2 版）。基于当前实际生效的键位（headless 导出 `nvim_get_keymap`，已触发 `VeryLazy`）。
> 环境：Debian on WSL2 / Windows Terminal 1.24 / Neovim 0.12.4
> 配套文档：`nvim-update.md`（插件选型与理由）

> **本版变更**：第四节的三处键位冲突已全部修复；extras 从 7 个增至 16 个；插件 33 → 48。

---

## 一、这套配置是什么

**LazyVim starter 模板**，面向 Angular / React / Electron 前端开发。

| 项目 | 值 |
|---|---|
| 发行版 | [LazyVim](https://www.lazyvim.org/) |
| 插件管理器 | lazy.nvim |
| 已装插件 | **48 个** |
| 启用的 extras | **16 个**（见 §1.2） |
| 配色 | tokyonight |
| Leader | `<Space>` |
| LocalLeader | `\` |
| 补全 | blink.cmp |
| 选择器 / 文件树 | snacks.nvim（picker + explorer） |
| 跳转 | flash.nvim |
| 会话 | persistence.nvim |
| TS 语言服务器 | vtsls |
| Lint | oxlint（LSP） |
| 格式化 | prettier → oxfmt（按项目自动选） |
| 调试 | nvim-dap + js-debug（pwa-node / pwa-chrome） |
| 测试 | neotest + neotest-vitest |

### 1.1 文件结构

```
~/.config/nvim/
├── init.lua                    # 仅 require("config.lazy")
├── lazy-lock.json              # 插件版本锁定（应提交到 git）
├── lazyvim.json                # 启用的 extras 列表（16 个）
└── lua/
    ├── config/
    │   ├── lazy.lua            # lazy.nvim 引导 + LazyVim 导入
    │   ├── options.lua         # 编辑器选项 + lazyvim_prettier_needs_config
    │   ├── keymaps.lua         # 自定义键位（仅 2 条）
    │   └── autocmds.lua        # 空
    └── plugins/
        ├── colorscheme.lua     # tokyonight
        ├── formatting.lua      # prettier / oxfmt 优先级
        ├── lsp.lua             # angularls root_dir 收窄
        └── neotest.lua         # vitest 适配器
```

### 1.2 启用的 extras

```
coding.mini-surround        editor.illuminate       editor.inc-rename
editor.refactoring          dap.core                formatting.prettier
lang.angular                lang.json               lang.tailwind
lang.typescript             lang.typescript.oxc     lang.typescript.vtsls
test.core                   ui.treesitter-context   util.mini-hipatterns
util.project
```

---

## 二、如何管理项目

项目管理靠三件东西：**会话持久化** + **根目录自动探测** + **snacks 项目选择器**。

### 2.1 会话持久化（persistence.nvim）

会话按 **cwd** 分文件存放，路径中的 `/` 编码成 `%`：

```
~/.local/state/nvim/sessions/
├── %home%delta%workspace%ai%molecrab.vim
├── %home%delta%cws-react%%refactor%tailwind-migration.vim
└── ...
```

| 键位 | 作用 |
|---|---|
| `<leader>qs` | 恢复**当前目录**的会话 |
| `<leader>ql` | 恢复**上一次**的会话 |
| `<leader>qS` | 列出所有会话来选 |
| `<leader>qd` | 本次退出**不保存**会话 |

> ⚠️ 会话按 **启动 nvim 时的 cwd** 索引。先 `cd` 进项目再开 nvim，否则存的是错的目录。

### 2.2 项目选择器

`<leader>fp` — snacks.picker 的项目列表（`util.project` extra 提供）。

### 2.3 根目录（Root Dir）探测

`LazyVim.root()` 按优先级：**LSP workspace → `.git` / `lua` 等标记 → cwd**。
大量键位因此成对出现，小写作用于 *root dir*，大写作用于 *cwd*：

| root dir | cwd | 作用 |
|---|---|---|
| `<leader>ff` | `<leader>fF` | 找文件 |
| `<leader>fr` | `<leader>fR` | 最近文件 |
| `<leader>e` | `<leader>E` | 文件树 |
| `<leader>sg` | `<leader>sG` | 全文 grep |
| `<leader>sw` | `<leader>sW` | 搜光标下的词 |
| `<leader>ft` | `<leader>fT` | 终端 |

`:LazyRoot` 查看当前探测到的根目录。

### 2.4 各项目实际生效的工具链

| 项目 | LSP | 格式化 |
|---|---|---|
| `~/cws-react` | oxlint, tailwindcss, vtsls | oxfmt |
| `~/workspace/ai/molecraft` | oxlint, tailwindcss, vtsls | oxfmt |
| `~/workspace/ai/capa-demo` | angularls, tailwindcss, vtsls | prettier |
| `~/workspace/ai/oneapp` | angularls, tailwindcss, vtsls | oxfmt |

---

## 三、快捷键统计

当前实际生效：**504 条**原始映射（按模式计），去重后 **337 个**唯一键位。

模式代号：`n` 普通 / `v` 可视+选择 / `x` 可视 / `s` 选择 / `o` 操作符待决 / `i` 插入 / `c` 命令行 / `t` 终端

### 3.1 分布概览

| 前缀 | 数量 | 用途 |
|---|---|---|
| `<leader>s` | 34 | 搜索（picker 全家桶） |
| `<leader>u` | 24 | UI 开关 |
| `<leader>d` | 22 | **调试 DAP**（本次新增） |
| `<leader>g` | 16 | Git |
| `<leader>f` | 14 | 文件查找 |
| `<leader>t` | 11 | **测试 neotest**（本次新增） |
| `<leader>b` | 10 | 缓冲区 |
| `<leader>r` | 8 | **重构**（本次新增） |
| `<leader>x` | 8 | 诊断与 quickfix |
| `<leader><Tab>` | 7 | 标签页 |
| `<leader>c` | 6 | 代码（+ LSP buffer-local，见 §3.16） |
| `<leader>q` | 5 | 会话与退出 |
| `<leader>w` | 2 | 窗口 |

---

### 3.2 Leader 顶层单键

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader> ` | `n` | Find Files (Root Dir) |
| `<leader>,` | `n` | Buffers |
| `<leader>-` | `n` | Split Window Below |
| `<leader>.` | `n` | Toggle Scratch Buffer |
| `<leader>/` | `n` | Grep (Root Dir) |
| `<leader>:` | `n` | Command History |
| `<leader>?` | `n` | Buffer Keymaps (which-key) |
| <code>&lt;leader&gt;`</code> | `n` | Switch to Other Buffer |
| `<leader>E` | `n` | Explorer Snacks (cwd) |
| `<leader>e` | `n` | Explorer Snacks (root dir) |
| `<leader>K` | `n` | Keywordprg |
| `<leader>L` | `n` | LazyVim Changelog |
| `<leader>l` | `n` | Lazy |
| `<leader>n` | `n` | Notification History |
| `<leader>r` | `nvx` | +refactor |
| `<leader>S` | `n` | Select Scratch Buffer |
| `<leader>t` | `n` | +test |
| `<leader>\|` | `n` | Split Window Right |

### 3.3 标签页 Tab — `<leader><Tab>`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader><Tab><Tab>` | `n` | New Tab |
| `<leader><Tab>[` | `n` | Previous Tab |
| `<leader><Tab>]` | `n` | Next Tab |
| `<leader><Tab>d` | `n` | Close Tab |
| `<leader><Tab>f` | `n` | First Tab |
| `<leader><Tab>l` | `n` | Last Tab |
| `<leader><Tab>o` | `n` | Close Other Tabs |

### 3.4 缓冲区 Buffer — `<leader>b`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>bb` | `n` | Switch to Other Buffer |
| `<leader>bD` | `n` | Delete Buffer and Window |
| `<leader>bd` | `n` | Delete Buffer |
| `<leader>bi` | `n` | Delete Invisible Buffers |
| `<leader>bj` | `n` | Pick Buffer |
| `<leader>bl` | `n` | Delete Buffers to the Left |
| `<leader>bo` | `n` | Delete Other Buffers |
| `<leader>bP` | `n` | Delete Non-Pinned Buffers |
| `<leader>bp` | `n` | Toggle Pin |
| `<leader>br` | `n` | Delete Buffers to the Right |

### 3.5 代码 Code / LSP — `<leader>c`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>cd` | `n` | Line Diagnostics |
| `<leader>cF` | `nvx` | Format Injected Langs |
| `<leader>cf` | `nvx` | Format |
| `<leader>cm` | `n` | Mason |
| `<leader>cS` | `n` | LSP references/definitions/... (Trouble) |
| `<leader>cs` | `n` | Symbols (Trouble) |

### 3.6 调试 Debug (DAP) — `<leader>d`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>da` | `n` | Run with Args |
| `<leader>dB` | `n` | Breakpoint Condition |
| `<leader>db` | `n` | Toggle Breakpoint |
| `<leader>dC` | `n` | Run to Cursor |
| `<leader>dc` | `n` | Run/Continue |
| `<leader>de` | `nvx` | Eval |
| `<leader>dg` | `n` | Go to Line (No Execute) |
| `<leader>di` | `n` | Step Into |
| `<leader>dj` | `n` | Down |
| `<leader>dk` | `n` | Up |
| `<leader>dl` | `n` | Run Last |
| `<leader>dO` | `n` | Step Over |
| `<leader>do` | `n` | Step Out |
| `<leader>dP` | `n` | Pause |
| `<leader>dph` | `n` | Toggle Profiler Highlights |
| `<leader>dpp` | `n` | Toggle Profiler |
| `<leader>dps` | `n` | Profiler Scratch Buffer |
| `<leader>dr` | `n` | Toggle REPL |
| `<leader>ds` | `n` | Session |
| `<leader>dt` | `n` | Terminate |
| `<leader>du` | `n` | Dap UI |
| `<leader>dw` | `n` | Widgets |

### 3.7 文件查找 File/Find — `<leader>f`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>fB` | `n` | Buffers (all) |
| `<leader>fb` | `n` | Buffers |
| `<leader>fc` | `n` | Find Config File |
| `<leader>fE` | `n` | Explorer Snacks (cwd) |
| `<leader>fe` | `n` | Explorer Snacks (root dir) |
| `<leader>fF` | `n` | Find Files (cwd) |
| `<leader>ff` | `n` | Find Files (Root Dir) |
| `<leader>fg` | `n` | Find Files (git-files) |
| `<leader>fn` | `n` | New File |
| `<leader>fp` | `n` | Projects |
| `<leader>fR` | `n` | Recent (cwd) |
| `<leader>fr` | `n` | Recent |
| `<leader>fT` | `n` | Terminal (cwd) |
| `<leader>ft` | `n` | Terminal (Root Dir) |

### 3.8 Git — `<leader>g`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>gB` | `nvx` | Git Browse (open) |
| `<leader>gb` | `n` | Git Blame Line |
| `<leader>gD` | `n` | Git Diff (origin) |
| `<leader>gd` | `n` | Git Diff (hunks) |
| `<leader>gf` | `n` | Git Current File History |
| `<leader>gG` | `n` | Lazygit (cwd) |
| `<leader>gg` | `n` | Lazygit (Root Dir) |
| `<leader>gI` | `n` | GitHub Issues (all) |
| `<leader>gi` | `n` | GitHub Issues (open) |
| `<leader>gL` | `n` | Git Log (cwd) |
| `<leader>gl` | `n` | Git Log |
| `<leader>gP` | `n` | GitHub Pull Requests (all) |
| `<leader>gp` | `n` | GitHub Pull Requests (open) |
| `<leader>gS` | `n` | Git Stash |
| `<leader>gs` | `n` | Git Status |
| `<leader>gY` | `nvx` | Git Browse (copy) |

### 3.9 会话与退出 Session/Quit — `<leader>q`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>qd` | `n` | Don't Save Current Session |
| `<leader>ql` | `n` | Restore Last Session |
| `<leader>qq` | `n` | Quit All |
| `<leader>qS` | `n` | Select Session |
| `<leader>qs` | `n` | Restore Session |

### 3.10 重构 Refactoring — `<leader>r`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>rc` | `n` | Debug Cleanup |
| `<leader>rF` | `nvx` | Extract Function To File |
| `<leader>rf` | `nvx` | Extract Function |
| `<leader>ri` | `nvx` | Inline Variable |
| `<leader>rP` | `n` | Debug Print Location |
| `<leader>rp` | `nvx` | Debug Print Variable |
| `<leader>rs` | `nvx` | Select Refactor |
| `<leader>rx` | `nvx` | Extract Variable |

### 3.11 搜索 Search — `<leader>s`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>s"` | `n` | Registers |
| `<leader>s/` | `n` | Search History |
| `<leader>sa` | `n` | Autocmds |
| `<leader>sB` | `n` | Grep Open Buffers |
| `<leader>sb` | `n` | Buffer Lines |
| `<leader>sC` | `n` | Commands |
| `<leader>sc` | `n` | Command History |
| `<leader>sD` | `n` | Buffer Diagnostics |
| `<leader>sd` | `n` | Diagnostics |
| `<leader>sG` | `n` | Grep (cwd) |
| `<leader>sg` | `n` | Grep (Root Dir) |
| `<leader>sH` | `n` | Highlights |
| `<leader>sh` | `n` | Help Pages |
| `<leader>si` | `n` | Icons |
| `<leader>sj` | `n` | Jumps |
| `<leader>sk` | `n` | Keymaps |
| `<leader>sl` | `n` | Location List |
| `<leader>sM` | `n` | Man Pages |
| `<leader>sm` | `n` | Marks |
| `<leader>sn` | `n` | +noice |
| `<leader>sna` | `n` | Noice All |
| `<leader>snd` | `n` | Dismiss All |
| `<leader>snh` | `n` | Noice History |
| `<leader>snl` | `n` | Noice Last Message |
| `<leader>snt` | `n` | Noice Picker (Telescope/FzfLua) |
| `<leader>sp` | `n` | Search for Plugin Spec |
| `<leader>sq` | `n` | Quickfix List |
| `<leader>sR` | `n` | Resume |
| `<leader>sr` | `nvx` | Search and Replace |
| `<leader>sT` | `n` | Todo/Fix/Fixme |
| `<leader>st` | `n` | Todo |
| `<leader>su` | `n` | Undotree |
| `<leader>sW` | `nvx` | Visual selection or word (cwd) |
| `<leader>sw` | `nvx` | Visual selection or word (Root Dir) |

### 3.12 测试 Test (neotest) — `<leader>t`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>ta` | `n` | Attach to Test (Neotest) |
| `<leader>td` | `n` | Debug Nearest |
| `<leader>tl` | `n` | Run Last (Neotest) |
| `<leader>tO` | `n` | Toggle Output Panel (Neotest) |
| `<leader>to` | `n` | Show Output (Neotest) |
| `<leader>tr` | `n` | Run Nearest (Neotest) |
| `<leader>tS` | `n` | Stop (Neotest) |
| `<leader>ts` | `n` | Toggle Summary (Neotest) |
| `<leader>tT` | `n` | Run All Test Files (Neotest) |
| `<leader>tt` | `n` | Run File (Neotest) |
| `<leader>tw` | `n` | Toggle Watch (Neotest) |

### 3.13 界面开关 UI Toggle — `<leader>u`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>uA` | `n` | Toggle Tabline |
| `<leader>ua` | `n` | Toggle Animations |
| `<leader>ub` | `n` | Toggle Dark Background |
| `<leader>uC` | `n` | Colorschemes |
| `<leader>uc` | `n` | Toggle Conceal Level |
| `<leader>uD` | `n` | Toggle Dimming |
| `<leader>ud` | `n` | Toggle Diagnostics |
| `<leader>uF` | `n` | Toggle Auto Format (Buffer) |
| `<leader>uf` | `n` | Toggle Auto Format (Global) |
| `<leader>ug` | `n` | Toggle Indent Guides |
| `<leader>uh` | `n` | Toggle Inlay Hints |
| `<leader>uI` | `n` | Inspect Tree |
| `<leader>ui` | `n` | Inspect Pos |
| `<leader>uL` | `n` | Toggle Relative Number |
| `<leader>ul` | `n` | Toggle Line Numbers |
| `<leader>un` | `n` | Dismiss All Notifications |
| `<leader>up` | `n` | Toggle Mini Pairs |
| `<leader>ur` | `n` | Redraw / Clear hlsearch / Diff Update |
| `<leader>uS` | `n` | Toggle Smooth Scroll |
| `<leader>us` | `n` | Toggle Spelling |
| `<leader>uT` | `n` | Toggle Treesitter Highlight |
| `<leader>uw` | `n` | Toggle Wrap |
| `<leader>uZ` | `n` | Toggle Zoom Mode |
| `<leader>uz` | `n` | Toggle Zen Mode |

### 3.14 窗口 Window — `<leader>w`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>wd` | `n` | Delete Window |
| `<leader>wm` | `n` | Toggle Zoom Mode |

### 3.15 诊断与列表 Diagnostics/Quickfix — `<leader>x`

| 键位 | 模式 | 说明 |
|---|---|---|
| `<leader>xL` | `n` | Location List (Trouble) |
| `<leader>xl` | `n` | Location List |
| `<leader>xQ` | `n` | Quickfix List (Trouble) |
| `<leader>xq` | `n` | Quickfix List |
| `<leader>xT` | `n` | Todo/Fix/Fixme (Trouble) |
| `<leader>xt` | `n` | Todo (Trouble) |
| `<leader>xX` | `n` | Buffer Diagnostics (Trouble) |
| `<leader>xx` | `n` | Diagnostics (Trouble) |

### 3.16 非 Leader 键位（含插件覆盖的内置键）

| 键位 | 模式 | 说明 |
|---|---|---|
| `"` | `ic` | Closeopen action for '""' pair |
| `#` | `vx` | :help v_#-default |
| `&` | `n` | :help &-default |
| `'` | `ic` | Closeopen action for "''" pair |
| `(` | `ic` | Open action for "()" pair |
| `)` | `ic` | Close action for "()" pair |
| `*` | `vx` | :help v_star-default |
| `<` | `vx` | Indent Left |
| `<BS>` | `ic` | MiniPairs <BS> |
| `<C-/>` | `nt` | Terminal (Root Dir) |
| `<C-_>` | `nt` | which_key_ignore |
| `<C-B>` | `nvsi` | Scroll Backward |
| `<C-Down>` | `n` | Decrease Window Height |
| `<C-F>` | `nvsi` | Scroll Forward |
| `<C-H>` | `n` | Go to Left Window |
| `<C-J>` | `n` | Go to Lower Window |
| `<C-K>` | `n` | Go to Upper Window |
| `<C-L>` | `n` | Go to Right Window |
| `<C-Left>` | `n` | Decrease Window Width |
| `<C-Right>` | `n` | Increase Window Width |
| `<C-S>` | `nvxsi` | Save File |
| `<C-S>` | `c` | Toggle Flash Search |
| `<C-Space>` | `nvxo` | Treesitter Incremental Selection |
| `<C-U>` | `i` | :help i_CTRL-U-default |
| `<C-Up>` | `n` | Increase Window Height |
| `<C-W>` | `i` | :help i_CTRL-W-default |
| `<C-W> ` | `n` | Window Hydra Mode (which-key) |
| `<C-W><C-D>` | `n` | Show diagnostics under the cursor |
| `<C-W>d` | `n` | Show diagnostics under the cursor |
| `<CR>` | `i` | MiniPairs <CR> |
| `<Down>` | `nvx` | Down |
| `<Esc>` | `nvsi` | Escape and Clear hlsearch |
| `<M-j>` | `nvxsi` | Move Down |
| `<M-k>` | `nvxsi` | Move Up |
| `<S-CR>` | `c` | Redirect Cmdline |
| `<S-Tab>` | `vsi` | vim.snippet.jump if active, otherwise <S-Tab> |
| `<Tab>` | `vsi` | vim.snippet.jump if active, otherwise <Tab> |
| `<Up>` | `nvx` | Up |
| `>` | `vx` | Indent Right |
| `@` | `vx` | :help v_@-default |
| `[` | `ic` | Open action for "[]" pair |
| `[ ` | `n` | Add empty line above cursor |
| `[<C-L>` | `n` | :lpfile |
| `[<C-Q>` | `n` | :cpfile |
| `[<C-T>` | `n` | :ptprevious |
| `[[` | `n` | Prev Reference |
| `[A` | `n` | :rewind |
| `[a` | `n` | :previous |
| `[B` | `n` | Move buffer prev |
| `[b` | `n` | Prev Buffer |
| `[D` | `n` | Jump to the first diagnostic in the current buffer |
| `[d` | `n` | Prev Diagnostic |
| `[e` | `n` | Prev Error |
| `[L` | `n` | :lrewind |
| `[l` | `n` | :lprevious |
| `[N` | `vx` | Select previous sibling node |
| `[n` | `vx` | Select previous node |
| `[Q` | `n` | :crewind |
| `[q` | `n` | Previous Trouble/Quickfix Item |
| `[T` | `n` | :trewind |
| `[t` | `n` | Previous Todo Comment |
| `[w` | `n` | Prev Warning |
| `]` | `ic` | Close action for "[]" pair |
| `] ` | `n` | Add empty line below cursor |
| `]<C-L>` | `n` | :lnfile |
| `]<C-Q>` | `n` | :cnfile |
| `]<C-T>` | `n` | :ptnext |
| `]]` | `n` | Next Reference |
| `]A` | `n` | :last |
| `]a` | `n` | :next |
| `]B` | `n` | Move buffer next |
| `]b` | `n` | Next Buffer |
| `]D` | `n` | Jump to the last diagnostic in the current buffer |
| `]d` | `n` | Next Diagnostic |
| `]e` | `n` | Next Error |
| `]L` | `n` | :llast |
| `]l` | `n` | :lnext |
| `]N` | `vx` | Select next sibling node |
| `]n` | `vx` | Select next node |
| `]Q` | `n` | :clast |
| `]q` | `n` | Next Trouble/Quickfix Item |
| `]T` | `n` | :tlast |
| `]t` | `n` | Next Todo Comment |
| `]w` | `n` | Next Warning |
| ``` | `ic` | Closeopen action for "``" pair |
| `a` | `vxo` | Around textobject |
| `al` | `vxo` | Around last textobject |
| `an` | `vxo` | Around next textobject |
| `g[` | `nvxo` | Move to left "around" |
| `g]` | `nvxo` | Move to right "around" |
| `gc` | `nvx` | Toggle comment |
| `gc` | `o` | Comment textobject |
| `gcc` | `n` | Toggle comment line |
| `gcO` | `n` | Add Comment Above |
| `gco` | `n` | Add Comment Below |
| `gO` | `n` | vim.lsp.buf.document_symbol() |
| `gra` | `nvx` | vim.lsp.buf.code_action() |
| `gri` | `n` | vim.lsp.buf.implementation() |
| `grn` | `n` | vim.lsp.buf.rename() |
| `grr` | `n` | vim.lsp.buf.references() |
| `grt` | `n` | vim.lsp.buf.type_definition() |
| `grx` | `n` | vim.lsp.codelens.run() |
| `gsa` | `nvx` | Add Surrounding |
| `gsd` | `n` | Delete Surrounding |
| `gsF` | `n` | Find Left Surrounding |
| `gsf` | `n` | Find Right Surrounding |
| `gsh` | `n` | Highlight Surrounding |
| `gsn` | `n` | Update `MiniSurround.config.n_lines` |
| `gsr` | `n` | Replace Surrounding |
| `gx` | `nvx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `H` | `n` | Prev Buffer |
| `i` | `vxo` | Inside textobject |
| `il` | `vxo` | Inside last textobject |
| `in` | `vxo` | Inside next textobject |
| `j` | `nvx` | Down |
| `k` | `nvx` | Up |
| `L` | `n` | Next Buffer |
| `N` | `nvxo` | Prev Search Result |
| `n` | `nvxo` | Next Search Result |
| `Q` | `vx` | :help v_Q-default |
| `R` | `vxo` | Treesitter Search |
| `r` | `o` | Remote Flash |
| `S` | `nvxo` | Flash Treesitter |
| `s` | `nvxo` | Flash |
| `Y` | `n` | :help Y-default |
| `{` | `ic` | Open action for "{}" pair |
| `}` | `ic` | Close action for "{}" pair |
### 3.16 LSP 键位（buffer-local，仅在 LSP 附着到该缓冲区时生效）

> 这组不会出现在全局 keymap 表里，需要打开一个有 LSP 的文件才存在。

| 键位 | 模式 | 说明 |
|---|---|---|
| `gd` | `n` | 跳转到定义 |
| `gr` | `n` | 查找引用 |
| `gI` | `n` | 跳转到实现 |
| `gy` | `n` | 跳转到类型定义 |
| `gD` | `n` | 跳转到声明 |
| `K` | `n` | 悬浮文档（覆盖内置 `K` keywordprg） |
| `gK` | `n` | 函数签名 |
| `<C-k>` | `i` | 函数签名（插入模式） |
| `<leader>ca` | `n` `x` | Code Action（oxlint 的自动修在这里） |
| `<leader>cc` / `<leader>cC` | `n` `x` | 运行 / 刷新 Codelens |
| `<leader>cr` | `n` | 重命名符号（**已接管为 inc-rename 实时预览**） |
| `<leader>cR` | `n` | 重命名文件（自动更新 import） |
| `<leader>cA` | `n` | Source Action |
| `<leader>co` | `n` | 整理 import |
| `<leader>cl` | `n` | LSP 信息 |
| `]]` / `[[` | `n` | 下/上一个引用高亮 |
| `<A-n>` / `<A-p>` | `n` | 下/上一个引用（带循环） |

---

## 四、快捷键冲突分析

> ✅ **本节记录的三处真冲突已于 2026-09-01 全部修复。** 保留记录供日后参考。

### 4.1 ✅ 已修复：自定义键位覆盖 LazyVim 上游

`lua/config/keymaps.lua` 在 `VeryLazy` 时加载，**晚于** LazyVim 自己的 `config/keymaps.lua`，所以自定义定义会赢。曾有三处问题：

#### ① `<Esc>` —— 功能退化 ✅ 已删除

原先自定义了 `map("n", "<Esc>", "<cmd>nohlsearch<CR>")`，覆盖掉 LazyVim 的版本：

```lua
-- LazyVim 上游（modes: i, n, s）
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  LazyVim.cmp.actions.snippet_stop()
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
```

丢失了两件事：`snippet_stop()`（snippet 跳转点残留），以及 `expr` 返回 `<esc>` 保留的原生语义（取消待决 count / operator）。而且只覆盖了 `n` 模式，导致与 `i`/`s` 行为不一致。

**修复**：删除该行，回归上游。

**验证**：现在 `<Esc>` 在 `n` / `v` / `s` / `i` 四个模式下统一为 `Escape and Clear hlsearch`（`<lua>` callback）。

#### ② `<C-h/j/k/l>` —— 纯粹重复 ✅ 已删除

与 LazyVim `config/keymaps.lua:14-17` 逐字重复，唯一差别是上游带 `remap = true`（为让 `<C-w>` 走 which-key Window Hydra）。实际效果相同，但重复定义意味着上游改动无法跟进。

**修复**：删除四行。**验证**：`<C-H/J/K/L>` 仍正常工作，现由上游提供。

#### ③ `<` / `>` —— 模式选错 ✅ 已改为 `x`

```lua
map("v", "<", "<gv")   -- ❌ v = x(可视) + s(选择)
map("x", "<", "<gv")   -- ✅ 仅可视模式
```

Vim 的 `v` 同时覆盖可视和**选择**模式。选择模式下按可打印字符本应替换选区（snippet 跳转点就工作在选择模式），原配置会让 `>` 变成缩进。

**修复**：改用 `x`。**验证**：键位 diff 显示恰好移除了 `('s','<')` 和 `('s','>')` 两条，可视模式功能不受影响。

#### 修复后的 `lua/config/keymaps.lua`

```lua
local map = vim.keymap.set

-- Keep selection when indenting visual blocks
-- NOTE: mode "x" (not "v") on purpose -- "v" also covers select mode.
map("x", "<", "<gv", { desc = "Indent Left" })
map("x", ">", ">gv", { desc = "Indent Right" })
```

---

### 4.2 ✅ 已修复：angularls 挂载到非 Angular 项目

`lang.angular` extra 注册的是 `angularls = {}`，**没有 `root_dir`**。lspconfig 解析不到根目录时会退化成 single-file 模式，把 Angular 语言服务器挂到**所有** TS/JS 缓冲区上——包括纯 React 项目。

实测 `~/cws-react/src/main.tsx` 曾挂载 `angularls, oxlint, tailwindcss, vtsls`。

**修复**：`lua/plugins/lsp.lua` 收窄 `root_dir`，需覆盖两种形态：

- **Angular CLI 工作区** —— 有 `angular.json` / `nx.json` / `project.json`
- **Vite/Analog 构建的 Angular 应用** —— `~/workspace/ai/oneapp` 用 `@analogjs/vite-plugin-angular`，**完全没有 `angular.json`**，只能回退到读 `package.json` 里的 `@angular/core`

**验证**（四个项目全部符合预期）：

| 项目 | 类型 | angularls |
|---|---|---|
| `cws-react` | React + Vite | ❌ 不挂载 ✅ |
| `molecraft` | Electron + React | ❌ 不挂载 ✅ |
| `capa-demo` | Angular CLI（有 angular.json） | ✅ 挂载 |
| `oneapp` | Angular + Analog/Vite（无 angular.json） | ✅ 挂载 |

---

### 4.3 🟡 插件覆盖 Vim 内置键（LazyVim 默认行为，保留）

这些是 LazyVim 的既定设计，不是缺陷，但要知道原键去哪了：

| 键位 | 模式 | 现在是 | 覆盖了内置 | 替代方案 |
|---|---|---|---|---|
| `s` | `n` `x` `o` | flash 跳转 | `s` = 删字符并插入 | 用 `cl` |
| `S` | `n` `x` `o` | flash treesitter | `S` = 删整行并插入 | 用 `cc` |
| `R` | `x` `o` | treesitter 搜索 | 可视模式 `R` = 改行 | 用 `c` |
| `H` | `n` | 上一个 buffer | `H` = 跳到屏幕顶行 | `:normal! H` |
| `L` | `n` | 下一个 buffer | `L` = 跳到屏幕底行 | `:normal! L` |
| `K` | `n` | LSP 悬浮文档 | `K` = 查 `keywordprg` | `:h <word>` |

**不算冲突的几个**（容易误判）：

- **`r`（`o` 模式）= Remote Flash** —— 只在操作符待决时生效（如 `dr`），**普通模式的 `r` 替换字符不受影响**
- **`<C-f>` / `<C-b>`** —— noice 的**软覆盖**：`if not require("noice.lsp").scroll(4) then return "<c-f>" end`，没有 LSP 浮窗时**自动回退**
- **`gc`** —— Neovim 0.10+ 已内置注释操作符，ts-comments.nvim 只修正 `commentstring`
- **`&`** —— `:help &-default`，本就是 Neovim 默认映射

---

### 4.4 🟢 前缀延迟（设计使然，无需处理）

| 前缀 | 被更长映射跟随 | 性质 |
|---|---|---|
| `<leader>sn` | 5 | which-key 分组标签 `+noice`，本身无动作 |
| `gc` | 3 | operator 等 motion，Vim 固有设计 |
| `a` / `i`（`o` `x` `v`） | 各 2~3 | mini.ai 文本对象前缀 |

**没有有害的前缀遮蔽** —— 不存在「真实动作被更长映射拖慢」的情况。

---

### 4.5 🔵 WSL / Windows Terminal 层面的键位失效

不是 nvim 配置问题，是**终端没把按键传进来**：

| 键位 | 作用 | 问题 |
|---|---|---|
| `<C-Space>` | Treesitter 增量选择 | Windows Terminal 默认不传 Ctrl+Space |
| `<S-CR>` | noice 重定向命令行 | 终端协议不区分 Shift+Enter |

**修法**：Windows Terminal `settings.json` 加 `sendInput` 动作，把这些键翻译成 CSI-u 序列（`ESC` 处填真实的 0x1B 字符）：

```json
{
    "command": { "action": "sendInput", "input": "ESC[32;5u" },
    "keys": "ctrl+space"
}
```

---

## 五、常用工作流速查

### 日常开发

| 场景 | 键位 |
|---|---|
| 打开项目 | `cd <项目>` → `nvim` → `<leader>qs` 恢复会话 |
| 切项目 | `<leader>fp` |
| 找文件 / 全文搜 | `<leader>ff` / `<leader>sg` |
| 文件树 | `<leader>e` |
| 跳转定义 / 引用 | `gd` / `gr` |
| 重命名（实时预览） | `<leader>cr` |
| Code Action（含 oxlint 自动修） | `<leader>ca` |
| 格式化 | 存盘自动（prettier 或 oxfmt） |
| 包裹 JSX 标签 | `ysat<div>`；改标签名 `cst` |

### 测试（vitest）

| 键位 | 作用 |
|---|---|
| `<leader>tt` | 跑当前文件 |
| `<leader>tr` | 跑最近的测试 |
| `<leader>ts` | 测试树 |
| `<leader>tw` | watch 模式 |
| `<leader>to` | 显示输出 |

### 调试（Electron / Node）

| 键位 | 作用 |
|---|---|
| `<leader>db` | 断点 |
| `<leader>dc` | 继续 / 启动 |
| `<leader>di` / `<leader>dO` / `<leader>do` | 步入 / 步过 / 步出 |
| `<leader>du` | 开关 DAP UI |
| `<leader>dt` | 终止 |

Electron 双进程调试需在项目 `.vscode/launch.json` 配 `pwa-node`（主进程）+ `pwa-chrome`（渲染进程），nvim-dap 会直接读取。已注册的适配器：`pwa-node` `pwa-chrome` `pwa-msedge`（及无前缀别名）。

### 重构

| 键位 | 作用 |
|---|---|
| `<leader>rf` | 提取函数 |
| `<leader>rx` | 提取变量 |
| `<leader>ri` | 内联变量 |
| `<leader>rs` | 重构菜单 |

---

## 六、遗留事项

| 事项 | 状态 |
|---|---|
| 安装 `fd`（加速 snacks.picker 找文件） | ✅ 已完成（10.2.0，软链在 `~/.local/bin/fd`） |
| `rg`（全文 grep 依赖） | ✅ 本就已装（ripgrep 14.1.1，`/usr/bin/rg`） |
| Electron `.vscode/launch.json` | ⏭️ 已决定不创建（见 §七） |
| 安装 `gh`（若要用 `util.octo`） | ⏳ 可选，当前未启用该 extra |
| `ng` 指向 Windows 的 scoop 二进制 | ⚠️ 建议一律 `npx ng` / `pnpm ng`，避免跨 WSL 边界 |

配置本身没有待办项。以下为可选的锦上添花，均**不影响使用**：

| 可选项 | 收益 | 命令 |
|---|---|---|
| `trash-cli` | 文件树删除进回收站而非永久删除 | `sudo apt-get install -y trash-cli` |
| 关闭未用的 provider | 少 5 条 checkhealth 警告，启动略快 | 见 §七 |
| `sqlite3` | snacks.picker 的 frecency 存数据库而非文件 | `sudo apt-get install -y sqlite3` |
| Neovim 0.12.5 | 当前 0.12.4，有小版本更新 | 按你的安装方式升级 |

---

## 七、体检结论（2026-09-01）

`:checkhealth` 报 14 ERROR / 18 WARNING，逐条核实后**没有一条需要处理**：

### 假阳性（headless 模式产物）

`setup did not run`、`vim.ui.input is not set to Snacks.input`、`vim.ui.select is not set`、`is not ready` —— 这些是在 `--headless` 下跑体检时插件尚未走完 `VeryLazy` 导致的，交互式使用中不存在。

### 与本机环境无关

`kitty` / `wezterm` / `ghostty`、`magick`、`gs`、`tectonic`、`mmdc`、`your terminal does not support the kitty graphics protocol` —— 全部属于 `snacks.image`（终端内联渲染图片）。**Windows Terminal 不支持 kitty graphics protocol**，这个功能在你的环境下根本无法启用，装齐依赖也没用。

### 不影响你的栈

- **Missing Treesitter languages: `latex, norg, svelte, typst, vue`** —— 都不在你的技术栈里。前端所需的 `typescript` `tsx` `javascript` `angular` `scss` `css` `html` `json` `jsonc` `yaml` 经 `vim.treesitter.language.add()` 实测**全部可用**，parser 在 `~/.local/share/nvim/site/parser/`
- **`tree-sitter (CLI)` is not installed** —— mason 已装（`~/.local/share/nvim/mason/bin/tree-sitter`），只是体检时 mason 未加载所以没进 PATH。所有需要的 parser 都已编译好，不影响使用
- **luarocks 未安装** —— 当前 48 个插件没有一个需要 luarocks
- **node / perl / python / ruby provider 缺失** —— LazyVim 不依赖这些远程插件宿主

若想让这 5 条 provider 警告消失（顺带省掉启动时的探测），在 `lua/config/options.lua` 追加：

```lua
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
```

### 其他

- **配置目录不是 git 仓库** —— `~/.config/nvim` 未做版本管理。`lazy-lock.json` 记录了 48 个插件的精确 commit，建议 `git init` 并提交，换机或插件更新出问题时可回滚
