return {
	{
		"olimorris/persisted.nvim",
		lazy = true,
		cmd = {
			"SessionToggle",
			"SessionStart",
			"SessionStop",
			"SessionSave",
			"SessionLoad",
			"SessionLoadLast",
			"SessionLoadFromFile",
			"SessionDelete",
		},
		config = require("editor.persisted"),
	},
	{ "m4xshen/autoclose.nvim", lazy = true, event = "InsertEnter", config = require("editor.autoclose") },
	{
		"pteroctopus/faster.nvim",
		lazy = false,
		cond = require("core.settings").load_big_files_faster,
		config = require("editor.faster"),
	},
	{ "ojroques/nvim-bufdel", lazy = true, cmd = { "BufDel", "BufDelAll", "BufDelOthers" } },
	{
		"folke/flash.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("editor.flash"),
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("editor.comment"),
	},
	{
		"sindrets/diffview.nvim",
		lazy = true,
		cmd = { "DiffviewOpen", "DiffviewClose" },
		config = require("editor.diffview"),
	},
	{
		"echasnovski/mini.align",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("editor.align"),
	},
	{
		"echasnovski/mini.cursorword",
		lazy = true,
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = require("editor.cursorword"),
	},
	{
		"smoka7/hop.nvim",
		lazy = true,
		version = "*",
		event = { "CursorHold", "CursorHoldI" },
		config = require("editor.hop"),
	},
	{
		"brenoprata10/nvim-highlight-colors",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("editor.highlight-colors"),
	},
	{ "romainl/vim-cool", lazy = true, event = { "CursorMoved", "InsertEnter" } },
	{ "lambdalisue/suda.vim", lazy = true, cmd = { "SudaRead", "SudaWrite" }, init = require("editor.suda") },
	{ "tpope/vim-sleuth", lazy = true, event = { "BufNewFile", "BufReadPost", "BufFilePost" } },
	{ "MagicDuck/grug-far.nvim", lazy = true, cmd = "GrugFar", config = require("editor.grug-far") },
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = function()
			if #vim.api.nvim_list_uis() > 0 then
				vim.api.nvim_command([[TSUpdate]])
			end
		end,
		config = require("editor.treesitter"),
		dependencies = {
			{ "mfussenegger/nvim-treehopper" },
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				config = require("editor.ts-textobjects"),
			},
			{ "andymass/vim-matchup", init = require("editor.matchup") },
			{ "windwp/nvim-ts-autotag", config = require("editor.autotag") },
			{
				"hiphish/rainbow-delimiters.nvim",
				submodules = false,
				config = require("editor.rainbow_delims"),
			},
			{ "nvim-treesitter/nvim-treesitter-context", config = require("editor.ts-context") },
			{ "JoosepAlviste/nvim-ts-context-commentstring", config = require("editor.ts-context-commentstring") },
		},
	},
}
