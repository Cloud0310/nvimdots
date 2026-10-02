# 工具安装、格式化与诊断

配置面向 Neovim 0.12+，直接修改仓库中的配置文件。

## 职责与入口

| 职责 | 实现 | 配置入口 |
| --- | --- | --- |
| Lua 插件安装 | lazy.nvim | `lua/plugins/`、`lazy-lock.json` |
| 外部工具安装 | Mason + mason-tool-installer | `lua/config/settings.lua` 的 `mason_tools` |
| LSP 配置与启用 | mason-lspconfig + 原生 LSP | `lua/plugins/lsp.lua` |
| 格式化 | Conform | `lua/plugins/conform.lua` |
| 格式化策略与命令 | Conform 的保存回调和手动入口 | `lua/util/formatting.lua` |
| 非 LSP 诊断 | none-ls，默认 Vint 检查 | `lua/plugins/completion.lua` |
| 诊断显示 | 原生 `vim.diagnostic` | `lua/config/diagnostics.lua` |
| DAP 配置 | mason-nvim-dap，仅配置适配器 | `lua/plugins/dap.lua`、`lua/util/dap.lua` |

插件文件返回原生 lazy.nvim spec，通过 `import = "plugins"` 加载。
LSP 参数在 `lua/plugins/lsp.lua` 的 `servers` 表中，通过 `vim.lsp.config()`
合并 nvim-lspconfig 默认配置，并在同一文件启用服务器。

## 外部工具安装

`lua/config/settings.lua` 的 `mason_tools` 是自动安装清单，使用 **Mason 包名**，
例如 `lua-language-server`、`clang-format`、`debugpy`。
直接编辑该列表即可调整安装工具。

- 启动后延迟三秒检查并安装缺失工具，不自动升级已有工具。
- `:MasonToolsInstall` 安装缺失工具或声明的指定版本。
- `:MasonToolsUpdate` 主动更新工具。
- `:Mason` 查看状态或手动管理单个工具。
- `:MasonToolsClean` 会卸载未写入清单的已安装工具。
- `lazy-lock.json` 只锁定插件；如需锁定外部工具版本，在 `mason_tools` 中声明。

清单控制安装。已安装且具有 LSP 映射的 Mason 包会被配置启用；新装 LSP
也会在同一会话中配置。`disabled_lsp_servers` 阻止已替换的服务器自动启用。
`rust-analyzer` 由 rustaceanvim 启动，避免重复客户端。
具体语言选择见 [语言工具链](language-toolchains.md)。

修改启动时安装行为时，直接调整 `lua/plugins/completion.lua` 中 mason-tool-installer 的
`run_on_start`、`start_delay` 等参数。

## 格式化

Conform 执行外部 formatter。没有可用外部 formatter 时，尝试允许的 LSP
formatter；外部命令执行失败不会触发该 fallback。
Go 使用 `lsp_format = "last"`，先运行 goimports，再调用开启 gofumpt 的 gopls。

文件类型映射和 formatter 参数在 `lua/plugins/conform.lua` 中。Lua 使用 StyLua，
C/C++ 等使用 clang-format，Python 使用 Ruff，Shell 使用 shfmt，TOML 使用 Tombi。
JS/TS、JSON、YAML、Markdown 等使用 npm 版 Oxfmt，具体支持范围见语言工具链文档。

clang-format 从当前文件向上寻找 `.clang-format` / `_clang-format`，没有项目配置时
使用 LLVM + 4 空格。Tombi 格式化使用离线/缓存 schema，避免保存时等待网络。

| 命令或按键 | 操作 |
| --- | --- |
| `:Format` / `<A-S-f>` | 手动格式化 |
| `:'<,'>Format` | 格式化所选范围 |
| `:FormatToggle` / `<A-f>` | 切换保存格式化，不影响手动格式化 |
| `:FormatterToggleFt lua` | 切换某文件类型的格式化 |
| `:ConformInfo` | 查看 formatter、可用状态和日志位置 |

共享设置在 `lua/config/settings.lua`：`format_on_save`、`format_timeout`、
`format_notify`、`formatter_block_list`、`format_disabled_dirs`、
`server_formatting_block_list`。
文件类型和目录排除同时作用于手动入口与保存格式化；server block list 只约束 LSP。
`format_notify` 控制手动格式化成功且产生修改时的提示，错误仍会显示。

`lua/util/formatting.lua` 提供策略和命令，Conform 注册保存 autocmd。
其他插件直接调用 `conform.format()` 时，需要显式传入所需的过滤和排除策略。
none-ls 只提供诊断，`:NullLsToggle` 不控制格式化。

## 原生诊断

当前行使用 `virtual_lines`，其他行使用 `virtual_text`，保留 signs、underline、
诊断浮窗和 Trouble。`diagnostics_level` 过滤虚拟显示，默认 HINT，不删除诊断数据。

- `g[` / `g]`：原生诊断跳转。
- `<leader>lx`：当前行诊断浮窗。
- `<leader>lv`：切换虚拟显示，诊断来源、signs 和 underline 不受影响。

Lspsaga 提供 hover、rename、code action 等操作。

## 检查配置

修改工具配置后，先用 `:Mason` 确认对应工具已安装，再在相关项目文件中查看
`:checkhealth vim.lsp`、`:ConformInfo` 和诊断。格式化可以在临时文件上执行
`:Format`，确认 formatter 选择和输出符合项目配置。
仓库保留 Lua lint 和 StyLua CI；语言功能的检查需要对应项目与工具链。
