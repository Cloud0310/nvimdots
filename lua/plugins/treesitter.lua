return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = function()
		if #vim.api.nvim_list_uis() > 0 then
			vim.api.nvim_command([[TSUpdate]])
		end
	end,
	config = vim.schedule_wrap(function()
		vim.api.nvim_set_option_value("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()", {})

		require("nvim-treesitter").setup({})

		require("nvim-treesitter").install(require("config.settings").treesitter_deps)
	end),
	dependencies = {
		{
			"mfussenegger/nvim-treehopper",
			keys = {
				{
					"m",
					":<C-u>lua require('tsht').nodes()<CR>",
					mode = "o",
					remap = true,
					silent = true,
					desc = "jump: Operate across syntax tree",
				},
			},
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			keys = {
				{
					"af",
					function()
						require("nvim-treesitter-textobjects.select").select_textobject(
							"@function.outer",
							"textobjects"
						)
					end,
					mode = { "x", "o" },
					silent = true,
					desc = "editxo: Select function.outer",
				},
				{
					"if",
					function()
						require("nvim-treesitter-textobjects.select").select_textobject(
							"@function.inner",
							"textobjects"
						)
					end,
					mode = { "x", "o" },
					silent = true,
					desc = "editxo: Select function.inner",
				},
				{
					"ac",
					function()
						require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
					end,
					mode = { "x", "o" },
					silent = true,
					desc = "editxo: Select class.outer",
				},
				{
					"ic",
					function()
						require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
					end,
					mode = { "x", "o" },
					silent = true,
					desc = "editoxo: Select class.inner",
				},
				{
					"<leader>a",
					function()
						require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
					end,
					silent = true,
					desc = "editn: Swap parameter.inner",
				},
				{
					"<leader>A",
					function()
						require("nvim-treesitter-textobjects.swap").swap_next("@parameter.outer")
					end,
					silent = true,
					desc = "editn: Swap parameter.outer",
				},
				{
					"][",
					function()
						require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to next function.outer start",
				},
				{
					"]m",
					function()
						require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to next class.outer start",
				},
				{
					"]]",
					function()
						require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to next function.outer end",
				},
				{
					"]M",
					function()
						require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to next class.outer end",
				},
				{
					"[[",
					function()
						require("nvim-treesitter-textobjects.move").goto_previous_start(
							"@function.outer",
							"textobjects"
						)
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to previous function.outer start",
				},
				{
					"[m",
					function()
						require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to previous class.outer start",
				},
				{
					"[]",
					function()
						require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to previous function.outer end",
				},
				{
					"[M",
					function()
						require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Move to previous class.outer end",
				},
				{
					";",
					function()
						require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next()
					end,
					mode = { "n", "x", "o" },
					silent = true,
					desc = "editnxo: Repeat last move",
				},
			},
			branch = "main",
			main = "nvim-treesitter-textobjects",
			opts = {
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
				},
				move = {
					set_jumps = true,
				},
			},
		},
		{
			"andymass/vim-matchup",
			init = function()
				vim.g.matchup_transmute_enabled = 1
				vim.g.matchup_surround_enabled = 1
				vim.g.matchup_matchparen_offscreen = { method = "popup" }
			end,
		},
		{
			"windwp/nvim-ts-autotag",
			main = "nvim-ts-autotag",
			opts = {
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			},
		},
		{
			"hiphish/rainbow-delimiters.nvim",
			submodules = false,
			config = function()
				---@param threshold number @Use global strategy if nr of lines exceeds this value
				local function init_strategy(threshold)
					return function()
						-- Disable on very large files
						local line_count = vim.api.nvim_buf_line_count(0)
						if line_count > 15000 then
							return nil
						end

						-- Disable on parser error
						local parser = vim.treesitter.get_parser()
						if not parser then
							return nil
						end
						local errors = 200
						parser:for_each_tree(function(lt)
							if lt:root():has_error() and errors >= 0 then
								errors = errors - 1
							end
						end)
						if errors < 0 then
							return nil
						end

						return line_count > threshold and require("rainbow-delimiters").strategy["global"]
							or require("rainbow-delimiters").strategy["local"]
					end
				end

				vim.g.rainbow_delimiters = {
					strategy = {
						[""] = init_strategy(500),
						c = init_strategy(300),
						cpp = init_strategy(300),
						lua = init_strategy(500),
						vimdoc = init_strategy(300),
						vim = init_strategy(300),
					},
					query = {
						[""] = "rainbow-delimiters",
						latex = "rainbow-blocks",
						javascript = "rainbow-delimiters-react",
					},
					highlight = {
						"RainbowDelimiterRed",
						"RainbowDelimiterOrange",
						"RainbowDelimiterYellow",
						"RainbowDelimiterGreen",
						"RainbowDelimiterBlue",
						"RainbowDelimiterCyan",
						"RainbowDelimiterViolet",
					},
				}
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			main = "treesitter-context",
			opts = {
				enable = true,
				line_numbers = true,
				max_lines = 3,
				min_window_height = 0,
				multiline_threshold = 20,
				trim_scope = "outer",
				mode = "cursor",
				-- Ensure compatibility with Glance's preview window
				zindex = 50,
			},
		},
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			main = "ts_context_commentstring",
			opts = function()
				vim.g.skip_ts_context_commentstring_module = 1
				return {
					-- Whether to update the `commentstring` on the `CursorHold` autocmd
					enable_autocmd = false,
				}
			end,
		},
	},
}
