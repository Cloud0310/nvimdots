# 语言工具链

## 当前选择

| 语言 | LSP / 诊断 | 格式化 | Neotest |
| --- | --- | --- | --- |
| C/C++ | clice | clang-format | 未绑定框架；需要按项目选择 GTest/Catch2/CTest 等适配器 |
| JS/TS/JSX/TSX | 原生 TypeScript（TS 7 tsc）+ Oxlint | Oxfmt | Vitest、Jest |
| Go | gopls + golangci-lint-langserver | goimports → gopls（gofumpt=true） | neotest-golang |
| JSON/JSONC | jsonls + SchemaStore.nvim | Oxfmt | — |
| YAML | yamlls + SchemaStore.nvim | Oxfmt | — |
| Markdown/MDX | Marksman | Oxfmt | — |
| TOML | Tombi | tombi format | — |
| Python | 原有 Pyrefly + Ruff | Ruff | neotest-python |
| Rust | rustaceanvim + rust-analyzer / Clippy | Conform → LSP → rustfmt | rustaceanvim.neotest |

外部工具统一在 `lua/core/settings.lua` 的 `mason_tools` 中声明。
重启后由 mason-tool-installer 补齐，也可以执行 `:MasonToolsInstall`。
没有自动卸载现有工具；`disabled_lsp_servers` 防止仍然安装着的旧服务器参与自动启用。

## C/C++：clice

`completion/lsp.lua` 的 `servers.clice` 定义 `clice serve`、C/C++ 文件类型、项目根标记和补全 capabilities。
旧 clangd 配置以及 clangd 专用命令已移除；clangd 仍然安装着也不会由本配置自动启用。

clice 不是编译器，也不替代 C/C++ 编译工具、clang-format 或 codelldb。
建议项目提供 compilation database，例如：

```sh
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

clice 搜索工作区及其直接子目录中的 `compile_commands.json`；复杂布局应配置 `clice.toml`。
本次接入标准 LSP 能力，没有额外引入 clice 仓库中的 Neovim 扩展 UI。

## JS/TS：原生 TypeScript + Oxc

### TypeScript 原生 LSP

使用的是原生 TypeScript 的 LSP 模式，不是 tsserver/typescript-language-server：

- Mason 包与 nvim-lspconfig 服务名均为 `tsc`，安装正式的 `typescript` 7+。
- 旧 `tsgo` 包（`@typescript/native-preview`）和 LSP 别名均已弃用，不再安装或映射到新服务。
- 上游配置查找支持 `--lsp` 的 TypeScript 7+ `tsc` 或 `tsgo`，跳过旧 TS 版本。
- 继承上游的 monorepo 和 Deno 根目录处理。
- 不同时启用旧 `ts_ls`、`vtsls`、`tsgo` 别名。

VS Code 的 `js/ts.experimental.useTsgo` 不是 Neovim 配置项；Neovim 直接启动原生 LSP。
项目可以使用 TS 7 的本地 `typescript`，或本地 `@typescript/native-preview`；全局兜底由 Mason 提供。

### Oxlint / Oxfmt

- Oxlint：`oxlint --lsp` 提供诊断和 code action；继承上游项目检测、本地命令优先和 `:LspOxlintFixAll`。
- 项目配置可以使用 `.oxlintrc.json` / `.oxlintrc.jsonc` / `oxlint.config.ts`，上游也支持识别 Vite+ 的 lint 配置。
- Oxfmt：Conform 直接运行，优先项目 `node_modules/.bin/oxfmt`，否则从 PATH（包括 Mason）查找。
- 独立 Prettier 已从安装清单及所有 formatter 映射中移除，不设 Prettier/prettierd fallback，也不迁移或模拟旧 Prettier 排版参数。
- Oxfmt 接管 JS/TS/JSX/TSX、JSON/JSONC/JSON5、YAML、HTML、Vue、CSS/SCSS/Less、Markdown/MDX、GraphQL。
- 需要 **npm 发行包 + Node.js**：Oxfmt 对 Markdown/HTML/Vue 等格式仍使用包内置的 Prettier 引擎；独立 Rust binary 不提供完整的这些格式支持。这不是本配置的独立 Prettier 依赖或 fallback。
- Svelte 必须在项目中安装 `svelte`，并在 Oxfmt 配置中设置 `"svelte": true`，否则 Oxfmt 可能不修改文件。
- Astro 当前不受 Oxfmt 支持，已移除其 formatter 映射，不用 Prettier 兜底。
- 不另外启动 Oxfmt LSP，避免双重格式化。
- Vue/Svelte/Astro 等框架的**完整语言支持**不等于 JS/TS LSP；本次没有添加各自的框架 language server。

如需类型感知 lint，项目应安装 `oxlint-tsgolint` 并配置 Oxlint 的 `options.typeAware`。
也可在 `completion/lsp.lua` 的 `servers.oxlint` 中显式设置 `settings.typeAware = true`。
不要仅安装普通 Oxlint 就假定所有类型感知规则均已生效。

### 其他 VoidZero 工具的边界

Vitest 已接入 Neotest；Vite/Vite+、Rolldown 等构建、开发服务器、依赖安装工具属于**项目工具链**。
本次不修改任何项目的 `package.json`、构建配置或包管理器，也不从 Neovim 全局安装 Vitest/Vite/Rolldown。
Neotest 适配器默认寻找项目 Vitest/Jest 可执行文件；Vite+ 的 `vp test` 若无独立 Vitest 命令，需要项目级适配，不把它假定为自动兼容。

## Go：参考 rami3l

参考 `rami3l/nvim-config` 的 Go 定制及其锁定的 AstroCommunity Go pack，移植功能而不依赖 AstroNvim：

- gopls：分析、CodeLens、inlay hints、staticcheck、未导入符号补全等，`shadow=false`。
- 保留参考方案和原配置中的 `-tags integration`；不需要时在用户 gopls 配置中替换。
- Gopher 替换 go.nvim，提供标签、测试生成、接口实现、错误处理等辅助功能。
- Mason 安装 gomodifytags、gotests、iferr、impl、goimports 等工具，不运行 `GoInstallBinaries` 或安装 build hook。
- golangci-lint + golangci-lint-langserver 提供额外检查。
- 格式化顺序是 goimports 后 gopls，gopls 开启 gofumpt。
- nvim-dap-go 唯一管理 Go debugger，通过 `dlv` 调试；移除旧 `go-debug-adapter` 安装及配置路径。
- Neotest 使用 neotest-golang，默认 `go test` runner，与参考配置一致；没有增加 gotestsum 安装要求。

Gopher 新版本的一些附加命令可能需要额外工具，例如 JSON 转结构体所需的 `json2go`；参考方案的默认 Mason 清单未提供它。
Neotest Go 默认参数包含 `-race`，需要可用的 Go/C 编译环境；不支持 race 的平台可在 Neotest 的用户配置中调整 adapter 参数。

## Rust：rustaceanvim

保留 `mrcjkb/rustaceanvim`，设置 `lazy = false`，让插件自己的 Rust ftplugin 负责按文件类型加载；不再叠加 lazy.nvim 的 `ft` 延迟加载。

职责划分：

- Mason 安装 rust-analyzer / CodeLLDB；mason-lspconfig 跳过 Rust，由 rustaceanvim 独占语言服务。
- 使用 rustaceanvim 默认的 `server.settings` 加载器：检测到 `cargo-clippy` 时启用保存检查 `clippy --no-deps`；未安装时保留 rust-analyzer 默认检查。
- Conform 不配置独立 Rust formatter，通过 LSP 调用 rustfmt；Cargo.toml 仍使用 Tombi，crates.nvim 仍提供依赖辅助。
- Neotest 使用 `rustaceanvim.neotest`，不增加 neotest-rust。
- 恢复 rustaceanvim 默认 DAP 配置及 Cargo 调试目标自动加载。C/C++ 的 CodeLLDB / LLDB 配置不再写入 `dap.configurations.rust`。
- CodeLLDB 的 adapter 可以共用，但 Rust 的构建、可执行文件定位和启动参数由 rustaceanvim 管理。首次连接后可能触发 Cargo 构建以生成调试目标。

操作入口：`:RustLsp runnables`、`:RustLsp debuggables`、`:RustLsp debug`；测试使用统一 `<leader>T…` 快捷键，通用 DAP 操作保持不变。

删除 Python `tomllib` 读取 `rust-analyzer.toml` 的自定义桥接，不维护旧加载逻辑。配置入口为 `lua/modules/configs/lang/rust.lua`。
用户定制放在 `lua/user/configs/rust.lua`，例如：

```lua
return function()
  vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim, {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
        },
      },
    },
  })
end
```

使用 `server.default_settings`，不要用自定义 `server.settings` 函数替换默认加载器。显式配置 `check.command` 可以覆盖自动 Clippy 选择。

Cargo/rustc 和组件由 Rust 工具链提供，不由 Neovim 安装：

```sh
rustup component add rust-src rustfmt clippy
```

本轮保留现有 Mason rust-analyzer 安装策略。上游建议使用与项目工具链匹配的 rust-analyzer；若项目固定工具链版本，应确认实际使用的版本（Mason 会影响 PATH 顺序），必要时通过 `server.cmd` 明确指定工具链对应的 rust-analyzer。

## YAML / JSON：SchemaStore

`schemastore.nvim` 提供完整目录，不再手写几个 JSON schema：

- JSON：`require("schemastore").json.schemas()`，开启校验。
- YAML：`require("schemastore").yaml.schemas()`。
- 关闭 yamlls 自带的 SchemaStore catalog 下载，避免重复目录来源。

目录在插件中，但 language server 仍可能按需下载具体 schema 文档；不等于完全离线验证。
项目自定义 schema 可在 `completion/lsp.lua` 的 `servers.jsonls` / `servers.yamlls` 中指定。

## Markdown：Marksman + Oxfmt

Mason 安装 `marksman`；`completion/lsp.lua` 的 `servers.marksman` 配置 `marksman server`，支持 Markdown 和 MDX 文件类型。
提供链接/标题补全、跨文档导航、引用、重命名和诊断。文档工作区应有 `.marksman.toml`（可以为空）或 Git 根目录。
MDX 中的 React/JSX 组件类型分析不由 Marksman 提供。

Conform 使用 Oxfmt 格式化 Markdown/MDX；沿用 Oxfmt 自身默认值/项目配置，不模拟旧 Prettier 参数。
保留已有 Treesitter、render-markdown（包括 CodeCompanion 渲染）及 markdown-preview；本次没有替换浏览器预览插件。
旧 formatter 参数入口不再读取，统一在 `user/configs/conform.lua` 定制。

## TOML：Tombi

Tombi 同时提供 LSP 诊断/补全和命令行格式化：

- `tombi lsp` 处理 TOML，项目根识别 `tombi.toml`、`pyproject.toml`、`Cargo.toml`、`.git`。
- Conform 执行 `tombi format --stdin-filename ... - --offline`，避免保存时等待 schema 网络请求。
- LSP 仍可按 Tombi 自身配置获取 schema；格式化使用本地缓存。
- Taplo 不再自动启用；Cargo.toml 的 crates.nvim 辅助功能保留。

## Neotest 操作

| 按键 | 操作 |
| --- | --- |
| `<leader>Tn` | 运行最近测试 |
| `<leader>T%` | 运行当前文件 |
| `<leader>Tl` | 重跑上次测试 |
| `<leader>Td` | 调试最近测试 |
| `<leader>Ts` | 测试结果树 |
| `<leader>To` | 输出浮窗 |
| `<leader>TO` | 输出面板 |
| `<leader>Tx` | 停止 |
| `<leader>Tw` | 监听当前文件 |

也可使用 `:Neotest` 命令。测试失败通过原生诊断显示。
JS 测试调试使用 Mason 的 `js-debug-adapter`，适配器名为 `pwa-node`。
Vitest/Jest、pytest 等测试运行器应由项目环境提供；安装 Neotest 不会替你安装项目依赖。

配置入口：`lua/modules/configs/tool/neotest.lua`，覆盖入口为 `lua/user/configs/neotest.lua`。
同一仓库混用多个 JS runner 时，需要按项目目录/文件匹配细化 adapter，而不是让两个 adapter 认领同一文件。

## 验证

从配置根目录运行：

```sh
# 先保证新插件已安装，并把 Mason bin 加入 PATH
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
nvim --headless -u NONE -l tests/toolchain.lua
nvim --headless -u NONE -l tests/language_toolchains.lua
nvim --headless -u NONE -l tests/neotest.lua
nvim --headless -u NONE -l tests/markdown.lua
nvim --headless -u NONE -l tests/rust.lua
```

- `toolchain.lua`：通用格式化、诊断和安装职责回归。
- `language_toolchains.lua`：清单/禁用策略、SchemaStore、真实 Oxfmt/Tombi 格式化，以及 clice/原生 TS/Oxlint/Tombi 的真实 LSP 诊断。
- `neotest.lua`：适配器配置与真实 Go 成功/失败测试运行。
- `markdown.lua`：全局无独立 Prettier fallback、Oxfmt 多格式真实格式化、Marksman 链接诊断和跨文件跳转（需要 npm 版 Oxfmt 和 Marksman）。
- `rust.lua`：真实 rustaceanvim 启动、Clippy 诊断、rustfmt、Rust Neotest 成功/失败测试、Cargo 调试目标生成和 CodeLLDB 会话；需要 Rust 工具链及上述组件、rust-analyzer、CodeLLDB。

测试不安装依赖、不访问 AI API、不修改现有项目。LSP 测试需要上述外部程序，Neotest 测试需要 Go parser、Go/C 编译工具。
可设置 `NVIM_TEST_PLUGIN_ROOT` 指定插件安装目录。

TypeScript 已改用正式的 Mason `tsc` 包（本机版本 7.0.2），不再依赖旧 native-preview 包。
真实 AI 请求、其他语言的 DAP 会话、Vitest/Jest/Python 项目的端到端测试不在本轮验证范围内。Rust 已用无外部依赖的临时 Cargo 项目验证测试和调试；不代表所有复杂 workspace/交叉编译环境都已覆盖。

本轮前的完整配置快照保存在本机：
`~/.local/state/nvim-config-backups/20260926-235402-language-toolchains/config.tar.gz`。
Rust 整理前的快照：`~/.local/state/nvim-config-backups/20260927-003051-rust/config.tar.gz`。
