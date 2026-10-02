# 工具链迁移：安装、格式化、诊断分离

本次保留 nvimdots 的组织方式、AI 配置、语言配置、搜索、UI 和调试功能，不重写成另一套发行版。
原生诊断的当前行显示配置面向 Neovim 0.12+。

## 职责

| 层 | 实现 | 配置入口 |
| --- | --- | --- |
| Lua 插件安装 | lazy.nvim | `lua/modules/plugins/`、`lazy-lock.json` |
| 外部工具安装 | Mason + mason-tool-installer | `core.settings.mason_tools` |
| LSP 配置与启用 | mason-lspconfig + 原生 LSP | `completion/lsp.lua` |
| 格式化 | Conform | `completion/conform.lua` |
| 非 LSP 诊断 | none-ls，仅保留默认 Vint 检查 | `completion/null-ls.lua` |
| 诊断显示 | 原生 `vim.diagnostic` | `lua/core/diagnostics.lua` |
| DAP 配置 | mason-nvim-dap，不再负责安装 | `tool/dap/` |

## 配置加载

插件文件返回原生 lazy.nvim spec 列表，由 `import = "modules.plugins"` 和 `import = "user.plugins"` 加载，不再自行 glob 扫描和转换插件字典。
LSP 参数集中在 `lua/modules/configs/completion/lsp.lua` 的 `servers` 表中，通过 `vim.lsp.config()` 直接合并 nvim-lspconfig 默认配置，并在同一文件启用服务器。不再拆分 `after/lsp/` 文件，也不读取旧 `user/configs/lsp-servers/` 或自定义 server handler。
用户配置采用 `vim.tbl_deep_extend`：字典合并、列表替换，函数作为值保留，不再执行嵌套函数来修改列表。已有配置文件内部的错误直接暴露，不静默回退。
AI 设置只使用下划线名称，不再识别旧连字符别名。

## 外部工具安装

`lua/core/settings.lua` 的 `mason_tools` 是唯一的默认自动安装清单，使用 **Mason 包名**。
例如 `lua-language-server`、`clang-format`、`debugpy`，而不是 `lua_ls`、`clang_format`、`python`。

- 启动后延迟三秒检查并安装缺失工具，不自动升级已有工具。
- `:MasonToolsInstall`：安装缺失工具或声明的指定版本。
- `:MasonToolsUpdate`：主动更新工具。
- `:Mason`：查看状态或手动管理单个工具。
- 不要随意使用 `:MasonToolsClean`：它会卸载未写入清单的已安装工具。
- 本次不会删除当前机器上手动安装的额外工具。
- `lazy-lock.json` 只锁定插件，不锁定 Mason 的外部工具；需要时在清单中声明工具版本。

旧的 `lsp_deps`、`null_ls_deps`、`dap_deps` 已移除。如果在自己的 `user/settings.lua` 中覆盖过它们，需转成 `mason_tools`。
用户列表直接替换默认列表：

```lua
-- lua/user/settings.lua
return {
  mason_tools = { "lua-language-server", "stylua" },
}
```

这只控制安装，不是插件/语言功能开关。已安装且具有 LSP 映射的 Mason 包会被配置启用；新装 LSP 也会在同一会话中配置。
`disabled_lsp_servers` 阻止旧 clangd/ts_ls/vtsls/tsgo/ESLint/Taplo 和 Oxfmt LSP 自动启用。
原生 TypeScript 直接使用 Mason `tsc` 包及同名 LSP，不再保留 `tsgo → tsc` 映射；`rust-analyzer` 的启动仍由 rustaceanvim 管理，防止重复客户端。
具体语言选择见 [语言工具链](language-toolchains.md)。

安装器的额外设置放在 `lua/user/configs/mason-tool-installer.lua`：

```lua
return { run_on_start = false } -- 只在手动执行安装命令时安装
```

## 格式化

Conform 直接执行 formatter；默认有外部工具时不再额外运行 LSP formatter，没有可用工具时才尝试允许的 LSP。
Go 是显式例外：使用 `lsp_format = "last"`，goimports 之后调用 gopls。
这不是“外部工具执行失败后再调用 LSP”的错误恢复策略。

默认映射：

- Lua：StyLua。
- C/C++/ObjC/C#/CUDA/Proto：clang-format。
- Go：goimports 后调用 gopls（`gofumpt = true`），与 rami3l 的方案一致。
- Python：ruff_format。
- Shell：shfmt。
- JS/TS/JSX/TSX、JSON/JSONC/JSON5、YAML、HTML、Vue、CSS/SCSS/Less、Markdown/MDX、GraphQL：Oxfmt，优先项目本地 npm 版本。
- Svelte：Oxfmt；项目必须安装 `svelte` 并开启 Oxfmt 的 `svelte` 选项。
- Astro：Oxfmt 不支持，不分配 formatter，也不保留 Prettier fallback。
- TOML：Tombi，使用离线/缓存 schema 避免保存等待网络。
- 其他类型（如 Rust）：有可用 LSP formatter 时 fallback。

clang-format 从当前文件所在位置向上寻找 `.clang-format` / `_clang-format`；找不到时使用 LLVM + 4 空格。
所有 formatter 定制统一放在 `user/configs/conform.lua`，不再读取旧的 `user/configs/formatters/clang_format.lua`。

Oxfmt 的 npm 发行包内部仍为 Markdown/HTML/Vue 等格式调用其内置 Prettier；配置只调用 Oxfmt，不另行安装或回退到 Prettier。
详见 [语言工具链](language-toolchains.md)。

操作入口：

| 命令/按键 | 含义 |
| --- | --- |
| `:Format` / `<A-S-f>` | 手动格式化 |
| `:'<,'>Format` | 格式化所选范围 |
| `:FormatToggle` / `<A-f>` | 切换保存格式化，不影响手动格式化 |
| `:FormatterToggleFt lua` | 切换某文件类型的格式化 |
| `:ConformInfo` | 查看选中的 formatter、可用状态、日志位置 |

保留 `format_on_save`、`format_timeout`、`format_notify`、`formatter_block_list`、`format_disabled_dirs`、`server_formatting_block_list`。
文件类型和目录排除同时作用于上述手动入口与保存格式化；server block list 只约束 LSP fallback，不影响外部 formatter。
`format_notify` 只控制手动格式化成功且产生修改时的提示，错误仍会显示。保存时不再弹出每次成功通知。

`completion/formatting.lua` 只提供策略和操作命令，不再自己发送 LSP 请求或安装保存 autocmd。
直接从其他插件调用 `conform.format()` 时，应显式传入所需的过滤/排除策略，不要假定它一定经过这些命令。

插件参数可在 `lua/user/configs/conform.lua` 覆盖。例如直接替换某个文件类型的 formatter 列表：

```lua
return {
  formatters_by_ft = {
    python = { "ruff_organize_imports", "ruff_format" },
  },
}
```

### 明确不兼容的旧功能

- 不维护旧格式化设置/入口的兼容层。
- `format_modifications_only` / lsp-format-modifications 已删除，不读取旧设置、不提供迁移警告；格式化整个 buffer 或显式选择的范围。
- 旧 `user/configs/formatters/clang_format.lua` 入口已删除，统一使用 Conform 配置。
- `NullLsToggle` 保留，但只管理 none-ls 的诊断 sources；不能再用来切换 formatter。
- 原 `user/configs/null-ls.lua` 中自定义的 formatting sources 应迁移到 Conform。
- none-ls 的默认 Vint 诊断保留，不能把安装 Vint 等同于 Conform 提供 lint。

## 原生诊断

- 当前行：`virtual_lines`。
- 其他行：`virtual_text`。
- 保留 signs、underline、诊断浮窗和 Trouble。
- 继续使用 `diagnostics_level` 过滤虚拟显示，默认 HINT；不会删除诊断数据。
- `g[` / `g]`：原生诊断跳转。
- `<leader>lx`：原生当前行诊断浮窗。
- `<leader>lv`：切换两种虚拟显示，不关闭诊断来源、signs 或 underline。

tiny-inline-diagnostic 已移除。Lspsaga 仍用于 hover、rename、code action 等非本次迁移的功能。

## 迁移前快照与回退

本次迁移前已创建本地 Git 检查点 `09f6ca6`，并保留分支 `backup/pre-toolchain-20260926-233042`。
包括被忽略的 `lua/user/` 在内的完整配置备份位于本机：

```text
~/.local/state/nvim-config-backups/20260926-233032/config.tar.gz
```

备份目录同时保存了迁移前暂存/未暂存 diff。Git 检查点不包含被忽略的用户文件，不能代替这个归档。
归档只包含配置，不包含已安装插件和 Mason 工具；旧插件目录没有被删除，可按旧 lockfile 恢复版本。

需要比较或回退时，先把归档解压到一个**新的空目录**，再比较/替换现有配置，避免覆盖后续修改。
也可以 `git worktree add /path/to/new-directory 09f6ca6` 查看迁移前已跟踪文件，再从归档补回 `lua/user/`。
本次迁移改动保留在工作区，尚未提交。

## 验证

`tests/toolchain.lua` 不下载工具、不调用 AI、不修改已有文件。
需要安装 Conform，并让 `stylua`、`clang-format` 在 PATH 中。默认查找 `stdpath('data')/site/lazy`，可通过 `NVIM_TEST_PLUGIN_ROOT` 指定插件目录。
从仓库根目录运行：

```sh
PATH="$HOME/.local/share/nvim/mason/bin:$PATH" \
  nvim --headless -u NONE -l tests/toolchain.lua
```

测试覆盖真实 Lua/C 格式化、保存时机、禁用策略、范围命令、LSP fallback、clang-format 项目配置、原生诊断，以及安装器/LSP 桥接职责。
新增依赖已单独锁定，没有批量更新原有插件。
