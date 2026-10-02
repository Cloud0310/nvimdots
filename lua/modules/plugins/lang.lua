return {
	{
		"kevinhwang91/nvim-bqf",
		lazy = true,
		ft = "qf",
		config = require("lang.bqf"),
		dependencies = { { "junegunn/fzf", build = ":call fzf#install()" } },
	},
	{
		"olexsmir/gopher.nvim",
		lazy = true,
		ft = { "go", "gomod", "gosum", "gowork" },
		config = require("lang.gopher"),
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "mason-org/mason.nvim" },
	},
	{
		"leoluz/nvim-dap-go",
		lazy = true,
		ft = "go",
		config = require("tool.dap.dap-go"),
		dependencies = { "mfussenegger/nvim-dap" },
	},
	{
		"mrcjkb/rustaceanvim",
		-- The plugin loads its Rust integration through ftplugin.
		lazy = false,
		version = "*",
		init = require("lang.rust"),
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"Saecki/crates.nvim",
		lazy = true,
		event = "BufReadPost Cargo.toml",
		config = require("lang.crates"),
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		lazy = true,
		ft = { "markdown", "codecompanion" },
		config = require("lang.render-markdown"),
	},
	{
		"iamcco/markdown-preview.nvim",
		lazy = true,
		ft = "markdown",
		build = ":call mkdp#util#install()",
	},
	{ "chrisbra/csv.vim", lazy = true, ft = "csv" },
}
