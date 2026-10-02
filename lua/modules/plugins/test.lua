return {
	{
		"nvim-neotest/neotest",
		lazy = true,
		cmd = "Neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"mfussenegger/nvim-dap",
			"leoluz/nvim-dap-go",
			"fredrikaverpil/neotest-golang",
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-jest",
			"nvim-neotest/neotest-python",
			"mrcjkb/rustaceanvim",
		},
		keys = {
			{
				"<leader>Tn",
				function()
					require("neotest").run.run()
				end,
				desc = "test: Run nearest",
			},
			{
				"<leader>T%",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "test: Run file",
			},
			{
				"<leader>Tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "test: Run last",
			},
			{
				"<leader>Td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "test: Debug nearest",
			},
			{
				"<leader>Ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "test: Toggle summary",
			},
			{
				"<leader>To",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "test: Show output",
			},
			{
				"<leader>TO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "test: Toggle output panel",
			},
			{
				"<leader>Tx",
				function()
					require("neotest").run.stop()
				end,
				desc = "test: Stop",
			},
			{
				"<leader>Tw",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "test: Watch file",
			},
		},
		config = require("tool.neotest"),
	},
}
