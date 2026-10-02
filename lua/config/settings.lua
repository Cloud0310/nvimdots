local settings = {}

-- Generic API key fetch from the Bitwarden CLI (`rbw`), cached per item.
-- Runs: rbw get <item> --field key
local key_cache = {}
local function get_rbw_key(item)
	if not key_cache[item] then
		local result = vim.system({ "rbw", "get", item, "--field", "key" }, { text = true }):wait(5000)
		if result.code == 124 then
			vim.notify(
				("Timed out fetching the rbw key for %s after 5s."):format(item),
				vim.log.levels.WARN,
				{ title = "rbw" }
			)
			key_cache[item] = ""
		else
			key_cache[item] = vim.trim(result.stdout)
		end
	end
	return key_cache[item]
end

-- Set to false if you want to use HTTPS to update plugins and Treesitter parsers.
---@type boolean
settings["use_ssh"] = false

-- Set to false if you don't use Copilot.
---@type boolean
settings["use_copilot"] = true

-- Default secret source for AI adapters. Set this to an environment variable
-- Examples:
--   "AI_API_KEY"
-- Recommended way of setting this environment variable, e.g.:
-- export AI_API_KEY=$(rbw get --field "API key" opencode\ go)
---@type string
settings["ai_api_key"] = "AI_API_KEY"

-- AI adapters for CodeCompanion and Minuet prediction.
-- Adapter `api_key` is optional; when omitted, `ai_api_key` is used.
---@type table<string, table>
settings["ai_adapters"] = {
	openrouter = {
		type = "openai-compatible",
		name = "OpenRouter",
		base_url = "https://openrouter.ai/api",
		chat_url = "/v1/chat/completions",
		models = {
			"moonshotai/kimi-k2:free",
			"qwen/qwen3-coder:free",
			"deepseek/deepseek-chat-v3-0324:free",
			"deepseek/deepseek-r1:free",
			"google/gemma-3-27b-it:free",
			"openai/codex-mini",
			"openai/gpt-4.1-mini",
			"google/gemini-2.5-flash-lite",
			"google/gemini-2.5-flash",
			"anthropic/claude-3.7-sonnet",
			"anthropic/claude-sonnet-4",
		},
		default_model = "moonshotai/kimi-k2:free",
		optional = {
			-- Disable thinking/reasoning for OpenRouter models if needed:
			-- reasoning = { effort = "none" },
		},
	},
	opencode = {
		api_key = function()
			return get_rbw_key("opencode go")
		end,
		type = "openai-compatible",
		name = "Opencode",
		base_url = "https://opencode.ai/zen/go",
		chat_url = "/v1/chat/completions",
		models = {
			"deepseek-v4-flash",
			"deepseek-v4-pro",
			"kimi-k2.6",
			"mimo-v2.5-pro",
			"glm-5.1",
		},
		default_model = "deepseek-v4-flash",
		optional = {
			thinking = { type = "disabled" },
		},
	},
	deepseek = {
		type = "openai-fim-compatible",
		name = "DeepSeek",
		api_key = function()
			return get_rbw_key("Deepseek")
		end,
		base_url = "https://api.deepseek.com/beta",
		chat_url = "/completions",
		models = { "deepseek-v4-flash" },
		default_model = "deepseek-v4-flash",
	},
	openai = {
		type = "builtin",
		adapter = "openai",
		name = "OpenAI",
		api_key = "OPENAI_API_KEY",
		models = { "gpt-4.1-mini", "gpt-5-mini" },
		default_model = "gpt-4.1-mini",
		optional = {
			-- Disable reasoning for OpenAI reasoning models if needed:
			-- reasoning_effort = "none",
		},
	},
}

-- Default CodeCompanion adapter. Must be a key in `ai_adapters`.
---@type string
settings["codecompanion_adapter"] = "opencode"

-- Completion prediction backend.
-- Valid values: `copilot`, `oai-compatible`.
---@type "copilot"|"oai-compatible"
settings["edit_prediction_source"] = "oai-compatible"

-- Default adapter for Minuet prediction. Must be a key in `ai_adapters`.
---@type string
settings["pred_adapter"] = "deepseek"

-- Model used by Minuet completion prediction.
---@type string
settings["pred_model"] = "deepseek-v4-flash"

-- Extra request parameters for Minuet completion prediction.
--
-- Examples for disabling thinking/reasoning:
--   OpenRouter: { reasoning = { effort = "none" } }
--   OpenCode go: { thinking = { type = "disabled" } }
--   OpenAI reasoning APIs: { reasoning_effort = "none" }
--
-- You may also set completion limits here, for example:
--   { max_tokens = 128 }
---@type table
settings["pred_optional_params"] = {
	reasoning_effort = "low",
	top_p = 0.9,
	max_tokens = 128,
}

-- Set to false if you don't want to format on save.
---@type boolean
settings["format_on_save"] = true

-- Format timeout in milliseconds.
---@type number
settings["format_timeout"] = 1000

-- Set to false to disable successful manual-format notifications (errors are always shown).
---@type boolean
settings["format_notify"] = true

-- Filetypes in this list will skip both external and LSP formatting if the value is true.
---@type table<string, boolean>
settings["formatter_block_list"] = {
	-- Example
	lua = false,
}

-- LSP clients excluded from Conform's fallback formatting. External formatters are unaffected.
---@type table<string, boolean>
settings["server_formatting_block_list"] = {
	clice = true, -- clang-format owns C/C++ formatting
	lua_ls = true,
	ruff = false,
	tsc = true, -- Oxfmt owns JS/TS formatting
	oxlint = true,
	tombi = true, -- Conform invokes tombi format directly
}

-- Directories where both manual and save-time formatting are disabled.
-- NOTE: Strings may contain regular expressions (vim regex). |regexp|
-- NOTE: Directories are automatically normalized using |vim.fs.normalize()|.
---@type string[]
settings["format_disabled_dirs"] = {
	-- Example
	"~/format_disabled_dir",
}

-- Show native virtual lines on the current line, virtual text on other lines (Neovim 0.12+).
-- Set to false to hide both virtual displays; signs, underline, floats and Trouble remain available.
---@type boolean
settings["diagnostics_virtual_lines"] = true

-- Set the minimum severity level of diagnostics to display.
-- Priority: `Error` > `Warning` > `Information` > `Hint`.
-- For example, if set to `Warning`, only warnings and errors will be shown.
-- NOTE: This only works when `diagnostics_virtual_lines` is true.
---@type "ERROR"|"WARN"|"INFO"|"HINT"
settings["diagnostics_level"] = "HINT"

-- Set to false if you don't use Neovim to open large files.
---@type boolean
settings["load_big_files_faster"] = true

-- Customize the global color palette here.
-- These settings will override the defaults during initialization.
-- Parameters will auto-complete as you type.
-- Example: { sky = "#04A5E5" }
---@type palette[]
settings["palette_overwrite"] = {}

-- Set the colorscheme here.
-- Valid options: `catppuccin`, `catppuccin-latte`, `catppuccin-mocha`, `catppuccin-frappe`, `catppuccin-macchiato`.
---@type string
settings["colorscheme"] = "catppuccin"

-- Set to true if your terminal supports a transparent background.
---@type boolean
settings["transparent_background"] = false

-- Set the background mode here.
-- Useful for themes with both light and dark variants.
-- Valid values: `dark`, `light`.
---@type "dark"|"light"
settings["background"] = "dark"

-- Set the command for opening external URLs.
-- This is ignored on Windows and macOS, which use built-in handlers.
---@type string
settings["external_browser"] = "chrome-cli open"

-- Set the search backend here.
-- `telescope` is fine for most use cases.
-- `fzf` is faster for large repos but needs the `fzf` binary in $PATH.
-- If missing, errors are expected until the binary is installed.
---@type "telescope"|"fzf"
settings["search_backend"] = "fzf"

-- Set to false to disable LSP inlay hints.
---@type boolean
settings["lsp_inlayhints"] = true

-- Do not auto-enable replaced servers even if their packages remain installed in Mason.
-- Oxfmt runs through Conform, not a second formatting LSP. Rust has its own owner.
---@type string[]
settings["disabled_lsp_servers"] = { "clangd", "ts_ls", "vtsls", "tsgo", "eslint", "taplo", "oxfmt" }

-- Single installation manifest, using Mason package names (not LSP/none-ls/DAP aliases).
-- Installation does not select a formatter or configure a debugger.
-- Installed language servers are configured by plugins/lsp.lua;
-- rust-analyzer remains owned by rustaceanvim.
---@type (string|table)[]
settings["mason_tools"] = {
	-- Language servers
	"bash-language-server",
	"clice",
	"gopls",
	"golangci-lint-langserver",
	"html-lsp",
	"json-lsp",
	"yaml-language-server",
	"marksman",
	"tombi",
	"tsc", -- TypeScript 7+ includes the native language server
	"oxlint",
	"lua-language-server",
	"ruff",
	"pyrefly",
	"rust-analyzer",
	-- Formatters and diagnostics
	"clang-format",
	"goimports", -- followed by gopls formatting with gofumpt=true
	"gomodifytags",
	"gotests",
	"iferr",
	"impl",
	"golangci-lint",
	"oxfmt", -- npm distribution is required for Markdown/HTML/Vue support
	"shfmt",
	"stylua",
	"vint", -- none-ls diagnostics only
	-- Debug adapters (mason-nvim-dap only configures them)
	"codelldb",
	"delve",
	"debugpy",
	"js-debug-adapter", -- Neotest Vitest/Jest debug strategy
}

-- Treesitter parsers to install during bootstrap.
-- Full list: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
---@type string[]
settings["treesitter_deps"] = {
	"bash",
	"c",
	"cpp",
	"css",
	"go",
	"gomod",
	"gosum",
	"gowork",
	"html",
	"javascript",
	"json",
	"latex",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"toml",
	"tsx",
	"typescript",
	"vimdoc",
	"vue",
	"yaml",
}

-- GUI settings for clients like `neovide` or `neovim-qt`.
-- NOTE: Only the following GUI options are supported; others will be ignored.
---@type { font_name: string, font_size: number }
settings["gui_config"] = {
	font_name = "JetBrainsMono Nerd Font",
	font_size = 12,
}

-- Specific settings for `neovide`.
-- Remove the `neovide_` prefix (with trailing underscore) from all entries below.
-- Supported entries: https://neovide.dev/configuration.html
---@type table<string, boolean|number|string>
settings["neovide_config"] = {
	no_idle = false,
	input_ime = true,
	fullscreen = true,
	padding_left = 8,
	confirm_quit = true,
	cursor_vfx_mode = "torpedo",
	cursor_trail_size = 0.05,
	cursor_antialiasing = true,
	hide_mouse_when_typing = true,
	input_macos_alt_is_meta = false,
	cursor_animation_length = 0.03,
	cursor_vfx_particle_speed = 20.0,
	cursor_vfx_particle_density = 5.0,
}

-- Set the dashboard startup image here.
-- Generate ASCII art with: https://github.com/TheZoraiz/ascii-image-converter
-- More info: https://github.com/ayamir/nvimdots/wiki/Issues#change-dashboard-startup-image
---@type string[]
settings["dashboard_image"] = {
	[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣡⣾⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣟⠻⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⡿⢫⣷⣿⣿⣿⣿⣿⣿⣿⣾⣯⣿⡿⢧⡚⢷⣌⣽⣿⣿⣿⣿⣿⣶⡌⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⠇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣇⣘⠿⢹⣿⣿⣿⣿⣿⣻⢿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⠀⢸⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣻⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⡇⠀⣬⠏⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣷⣼⣿⣿⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⠀⠈⠁⠀⣿⡇⠘⡟⣿⣿⣿⣿⣿⣿⣿⣿⡏⠿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⡏⠀⠀⠐⠀⢻⣇⠀⠀⠹⣿⣿⣿⣿⣿⣿⣩⡶⠼⠟⠻⠞⣿⡈⠻⣟⢻⣿⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢿⠀⡆⠀⠘⢿⢻⡿⣿⣧⣷⢣⣶⡃⢀⣾⡆⡋⣧⠙⢿⣿⣿⣟⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⡥⠂⡐⠀⠁⠑⣾⣿⣿⣾⣿⣿⣿⡿⣷⣷⣿⣧⣾⣿⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⡿⣿⣍⡴⠆⠀⠀⠀⠀⠀⠀⠀⠀⣼⣄⣀⣷⡄⣙⢿⣿⣿⣿⣿⣯⣶⣿⣿⢟⣾⣿⣿⢡⣿⣿⣿⣿⣿]],
	[[⣿⡏⣾⣿⣿⣿⣷⣦⠀⠀⠀⢀⡀⠀⠀⠠⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣡⣾⣿⣿⢏⣾⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⣿⣿⣿⣿⣿⡴⠀⠀⠀⠀⠀⠠⠀⠰⣿⣿⣿⣷⣿⠿⠿⣿⣿⣭⡶⣫⠔⢻⢿⢇⣾⣿⣿⣿⣿⣿⣿]],
	[[⣿⣿⣿⡿⢫⣽⠟⣋⠀⠀⠀⠀⣶⣦⠀⠀⠀⠈⠻⣿⣿⣿⣾⣿⣿⣿⣿⡿⣣⣿⣿⢸⣾⣿⣿⣿⣿⣿⣿⣿]],
	[[⡿⠛⣹⣶⣶⣶⣾⣿⣷⣦⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠉⠛⠻⢿⣿⡿⠫⠾⠿⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⡆⣠⢀⣴⣏⡀⠀⠀⠀⠉⠀⠀⢀⣠⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⠿⠛⠛⠛⠛⠛⠛⠻⢿⣿⣿⣿⣿⣯⣟⠷⢷⣿⡿⠋⠀⠀⠀⠀⣵⡀⢠⡿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
	[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⢿⣿⣿⠂⠀⠀⠀⠀⠀⢀⣽⣿⣿⣿⣿⣿⣿⣿⣍⠛⠿⣿⣿⣿⣿⣿⣿]],
}

-- Set it to false if you don't use AI chat functionality.
---@type boolean
settings["use_chat"] = true

-- Set the language to use for AI chat response here.
--- @type string
settings["chat_lang"] = "English"

return settings
