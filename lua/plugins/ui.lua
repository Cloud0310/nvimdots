return {
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			auto_attach = true,
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				vim.keymap.set("n", "]g", function()
					if vim.wo.diff then
						return "]g"
					end
					vim.schedule(function()
						gitsigns.nav_hunk("next")
					end)
					return "<Ignore>"
				end, { expr = true, replace_keycodes = false, buffer = bufnr, desc = "git: Goto next hunk" })

				vim.keymap.set("n", "[g", function()
					if vim.wo.diff then
						return "[g"
					end
					vim.schedule(function()
						gitsigns.nav_hunk("prev")
					end)
					return "<Ignore>"
				end, { expr = true, replace_keycodes = false, buffer = bufnr, desc = "git: Goto prev hunk" })

				vim.keymap.set("n", "<leader>gs", function()
					gitsigns.stage_hunk()
				end, { buffer = bufnr, desc = "git: Toggle staging/unstaging of hunk" })

				vim.keymap.set("v", "<leader>gs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "git: Toggle staging/unstaging of selected hunk" })

				vim.keymap.set("n", "<leader>gr", function()
					gitsigns.reset_hunk()
				end, { buffer = bufnr, desc = "git: Reset hunk" })

				vim.keymap.set("v", "<leader>gr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "git: Reset hunk" })

				vim.keymap.set("n", "<leader>gR", function()
					gitsigns.reset_buffer()
				end, { buffer = bufnr, desc = "git: Reset buffer" })

				vim.keymap.set("n", "<leader>gp", function()
					gitsigns.preview_hunk()
				end, { buffer = bufnr, desc = "git: Preview hunk" })

				vim.keymap.set("n", "<leader>gb", function()
					gitsigns.blame_line({ full = true })
				end, { buffer = bufnr, desc = "git: Blame line" })

				vim.keymap.set({ "o", "x" }, "ih", function()
					gitsigns.select_hunk()
				end, { buffer = bufnr })
			end,
			signcolumn = true,
			sign_priority = 6,
			update_debounce = 100,
			word_diff = false,
			current_line_blame = true,
			diff_opts = { internal = true },
			watch_gitdir = { follow_files = true },
			current_line_blame_opts = { delay = 1000, virt_text = true, virtual_text_pos = "eol" },
		},
	},
	{
		"karb94/neoscroll.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "neoscroll",
		opts = {
			hide_cursor = true,
			stop_eof = true,
			use_local_scrolloff = false,
			respect_scrolloff = false,
			cursor_scrolls_alone = true,
			-- All these keys will be mapped to their corresponding default scrolling animation
			mappings = {
				"<C-u>",
				"<C-d>",
				"<C-b>",
				"<C-f>",
				"<C-y>",
				"<C-e>",
				"zt",
				"zz",
				"zb",
			},
		},
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			local icons = {
				diagnostics = require("util.icons").get("diagnostics"),
				ui = require("util.icons").get("ui"),
			}

			require("notify").setup({
				stages = "fade",
				render = "default",
				fps = 20,
				timeout = 2000,
				minimum_width = 50,
				background_colour = "NotifyBackground",
				icons = {
					ERROR = icons.diagnostics.Error,
					WARN = icons.diagnostics.Warning,
					INFO = icons.diagnostics.Information,
					DEBUG = icons.ui.Bug,
					TRACE = icons.ui.Pencil,
				},
				on_open = function(win)
					vim.api.nvim_set_option_value("winblend", 0, { scope = "local", win = win })
					vim.api.nvim_win_set_config(win, { zindex = 90 })
				end,
				-- notifications with level lower than this would be ignored. [ERROR > WARN > INFO > DEBUG > TRACE]
				level = "INFO",
			})

			vim.notify = notify
		end,
	},
	{
		"folke/paint.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "paint",
		opts = {
			highlights = {
				{
					filter = { filetype = "lua" },
					pattern = "%s*%-%-%-%s*(@%w+)",
					hl = "Constant",
				},
				{
					filter = { filetype = "python" },
					pattern = "%s*([_%w]+:)",
					hl = "Constant",
				},
			},
		},
	},
	{
		"mrjones2014/smart-splits.nvim",
		keys = {
			{ "<A-h>", ":<C-u>SmartResizeLeft<CR>", silent = true, desc = "window: Resize -3 horizontally" },
			{ "<A-j>", ":<C-u>SmartResizeDown<CR>", silent = true, desc = "window: Resize -3 vertically" },
			{ "<A-k>", ":<C-u>SmartResizeUp<CR>", silent = true, desc = "window: Resize +3 vertically" },
			{ "<A-l>", ":<C-u>SmartResizeRight<CR>", silent = true, desc = "window: Resize +3 horizontally" },
			{ "<C-h>", ":<C-u>SmartCursorMoveLeft<CR>", silent = true, desc = "window: Focus left" },
			{ "<C-j>", ":<C-u>SmartCursorMoveDown<CR>", silent = true, desc = "window: Focus down" },
			{ "<C-k>", ":<C-u>SmartCursorMoveUp<CR>", silent = true, desc = "window: Focus up" },
			{ "<C-l>", ":<C-u>SmartCursorMoveRight<CR>", silent = true, desc = "window: Focus right" },
			{ "<leader>Wh", ":<C-u>SmartSwapLeft<CR>", silent = true, desc = "window: Move window leftward" },
			{ "<leader>Wj", ":<C-u>SmartSwapDown<CR>", silent = true, desc = "window: Move window downward" },
			{ "<leader>Wk", ":<C-u>SmartSwapUp<CR>", silent = true, desc = "window: Move window upward" },
			{ "<leader>Wl", ":<C-u>SmartSwapRight<CR>", silent = true, desc = "window: Move window rightward" },
		},
		lazy = true,
		event = { "CursorHoldI", "CursorHold" },
		main = "smart-splits",
		opts = {
			-- The default number of lines/columns to resize by at a time
			default_amount = 3,
			ignored_buftypes = {
				"nofile",
				"quickfix",
				"prompt",
			},
			ignored_filetypes = { "NvimTree" },
		},
	},
	{
		"folke/todo-comments.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "todo-comments",
		opts = function()
			local icons = {
				diagnostics = require("util.icons").get("diagnostics"),
				ui = require("util.icons").get("ui"),
			}
			return {
				signs = false, -- show icons in the signs column
				keywords = {
					FIX = {
						icon = icons.ui.Bug,
						color = "error",
						alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
					},
					TODO = { icon = icons.ui.Accepted, color = "info" },
					-- HACK = { icon = icons.ui.Fire, color = "warning" },
					WARN = { icon = icons.diagnostics.Warning, color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = icons.ui.Perf, alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = icons.ui.Note, color = "hint", alt = { "INFO" } },
					TEST = { icon = icons.ui.Lock, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				},
				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},
				merge_keywords = true,
				highlight = {
					multiline = false,
					keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty.
					after = "",
					comments_only = true,
					max_line_len = 500,
					exclude = {
						"alpha",
						"checkhealth",
						"dap-repl",
						"diff",
						"help",
						"log",
						"notify",
						"NvimTree",
						"Outline",
						"qf",
						"TelescopePrompt",
						"toggleterm",
						"undotree",
					},
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#F5C2E7" },
					default = { "Conditional", "#7C3AED" },
				},
			}
		end,
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"dstein64/nvim-scrollview",
		lazy = true,
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		main = "scrollview",
		opts = function()
			local icons = { diagnostics = require("util.icons").get("diagnostics", true) }
			return {
				mode = "virtual",
				winblend = 0,
				signs_on_startup = { "folds", "marks", "search" },
				diagnostics_error_symbol = icons.diagnostics.Error,
				diagnostics_warn_symbol = icons.diagnostics.Warning,
				diagnostics_info_symbol = icons.diagnostics.Information,
				diagnostics_hint_symbol = icons.diagnostics.Hint,
				excluded_filetypes = {
					"alpha",
					"fugitive",
					"git",
					"notify",
					"NvimTree",
					"TelescopePrompt",
					"toggleterm",
					"undotree",
				},
			}
		end,
	},
}
