local settings = require("core.settings")
local edit_prediction_source = settings.edit_prediction_source
local use_copilot_prediction = settings.use_copilot and edit_prediction_source == "copilot"
local use_minuet_prediction = edit_prediction_source == "oai-compatible"

return {
	{
		"mason-org/mason.nvim",
		lazy = true,
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonUpdate", "MasonLog" },
		config = require("completion.mason").setup,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- Register its VimEnter installation check before startup finishes.
		lazy = false,
		dependencies = { "mason-org/mason.nvim" },
		config = require("completion.mason-tool-installer"),
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("completion.lsp"),
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim" },
			{ "folke/neoconf.nvim" },
			{ "b0o/schemastore.nvim" },
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		lazy = true,
		event = "LspAttach",
		config = require("completion.lspsaga"),
		dependencies = "nvim-tree/nvim-web-devicons",
	},
	{
		"stevearc/conform.nvim",
		lazy = true,
		event = "BufWritePre",
		cmd = { "ConformInfo", "Format", "FormatToggle", "FormatterToggleFt" },
		config = require("completion.conform"),
	},
	{
		"nvimtools/none-ls.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("completion.null-ls"),
		dependencies = { "nvim-lua/plenary.nvim", "mason-org/mason.nvim" },
	},
	{
		"saghen/blink.cmp",
		lazy = true,
		version = "1.*",
		event = { "VeryLazy", "InsertEnter", "CmdlineEnter" },
		config = require("completion.blink"),
		dependencies = {
			{ "saghen/blink.compat", version = "2.*", opts = {} },
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
				config = require("completion.luasnip"),
				dependencies = "rafamadriz/friendly-snippets",
			},
			{ "andersevenrud/cmp-tmux" },
			{ "f3fora/cmp-spell" },
			{ "kdheepak/cmp-latex-symbols" },
			{ "mikavilpas/blink-ripgrep.nvim" },
			{ "xzbdmw/colorful-menu.nvim" },
			{
				"milanglacier/minuet-ai.nvim",
				cond = use_minuet_prediction,
				config = require("completion.minuet"),
			},
			{
				"fang2hou/blink-copilot",
				cond = use_copilot_prediction,
				dependencies = {
					{
						"zbirenbaum/copilot.lua",
						lazy = true,
						cond = use_copilot_prediction,
						cmd = "Copilot",
						event = "InsertEnter",
						config = require("completion.copilot"),
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"folke/lazydev.nvim",
		lazy = true,
		ft = "lua",
		config = require("completion.lazydev"),
	},
}
