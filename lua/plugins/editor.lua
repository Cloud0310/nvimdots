return {
	{
		"olimorris/persisted.nvim",
		keys = {
			{ "<leader>ss", ":<C-u>SessionSave<CR>", silent = true, desc = "session: Save" },
			{ "<leader>sl", ":<C-u>SessionLoad<CR>", silent = true, desc = "session: Load current" },
			{ "<leader>sd", ":<C-u>SessionDelete<CR>", silent = true, desc = "session: Delete" },
		},
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
		main = "persisted",
		opts = function()
			return {
				save_dir = vim.fn.stdpath("data") .. "/sessions/",
				autostart = true,
				-- Set `lazy = false` in `plugins/editor.lua` to enable this
				autoload = false,
				follow_cwd = true,
				use_git_branch = true,
				should_save = function()
					return vim.bo.filetype == "alpha" and false or true
				end,
			}
		end,
	},
	{
		"m4xshen/autoclose.nvim",
		lazy = true,
		event = "InsertEnter",
		main = "autoclose",
		opts = {
			keys = {
				["("] = { escape = false, close = true, pair = "()" },
				["["] = { escape = false, close = true, pair = "[]" },
				["{"] = { escape = false, close = true, pair = "{}" },

				["<"] = { escape = true, close = true, pair = "<>", enabled_filetypes = { "rust" } },
				[">"] = { escape = true, close = false, pair = "<>" },
				[")"] = { escape = true, close = false, pair = "()" },
				["]"] = { escape = true, close = false, pair = "[]" },
				["}"] = { escape = true, close = false, pair = "{}" },

				['"'] = { escape = true, close = true, pair = '""' },
				["`"] = { escape = true, close = true, pair = "``" },
				["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = { "rust" } },
			},
			options = {
				disable_when_touch = false,
				disabled_filetypes = {
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
					"vimwiki",
				},
			},
		},
	},
	{
		"pteroctopus/faster.nvim",
		lazy = false,
		cond = require("config.settings").load_big_files_faster,
		main = "faster",
		opts = {
			behaviours = {
				bigfile = {
					on = true,
					features_disabled = {
						"filetype",
						"indent_blankline",
						"lsp",
						"matchparen",
						"syntax",
						"treesitter",
						"vimopts",
					},
					filesize = 2, -- size of the file in MiB
				},
				fastmacro = {
					on = true,
					features_disabled = { "lualine" },
				},
			},
			features = {
				-- Neovim filetype plugin
				-- https://neovim.io/doc/user/filetype.html
				filetype = {
					on = true,
					defer = true,
				},
				-- Indent Blankline
				-- https://github.com/lukas-reineke/indent-blankline.nvim
				indent_blankline = {
					on = true,
					defer = false,
				},
				-- Neovim LSP
				-- https://neovim.io/doc/user/lsp.html
				lsp = {
					on = true,
					defer = false,
				},
				-- Lualine
				-- https://github.com/nvim-lualine/lualine.nvim
				lualine = {
					on = true,
					defer = false,
				},
				-- Neovim Pi_paren plugin
				-- https://neovim.io/doc/user/pi_paren.html
				matchparen = {
					on = true,
					defer = false,
				},
				-- Neovim syntax
				-- https://neovim.io/doc/user/syntax.html
				syntax = {
					on = true,
					defer = true,
				},
				-- Neovim treesitter
				-- https://neovim.io/doc/user/treesitter.html
				treesitter = {
					on = true,
					defer = false,
				},
				-- Neovim options that affect speed when big file is opened:
				-- swapfile, foldmethod, undolevels, undoreload, list
				vimopts = {
					on = true,
					defer = false,
				},
			},
		},
	},
	{
		"ojroques/nvim-bufdel",
		keys = {
			{ "<A-q>", ":BufDel<CR>", silent = true, desc = "buffer: Close current" },
		},
		lazy = true,
		cmd = { "BufDel", "BufDelAll", "BufDelOthers" },
	},
	{
		"folke/flash.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "flash",
		opts = function()
			vim.api.nvim_set_hl(
				0,
				"FlashLabel",
				{ underline = true, bold = true, fg = "Orange", bg = "NONE", ctermfg = "Red", ctermbg = "NONE" }
			)
			return {
				labels = "asdfghjklqwertyuiopzxcvbnm",
				label = {
					-- allow uppercase labels
					uppercase = true,
					-- add a label for the first match in the current window.
					-- you can always jump to the first match with `<CR>`
					current = true,
					-- for the current window, label targets closer to the cursor first
					distance = true,
				},
				modes = {
					search = { enabled = false },
					-- options used when flash is activated through
					-- `f`, `F`, `t`, `T`, `;` and `,` motions
					char = {
						enabled = true,
						-- hide after jump when not using jump labels
						autohide = false,
						-- show jump labels
						jump_labels = false,
						-- set to `false` to use the current line only
						multi_line = true,
						-- When using jump labels, don't use these keys
						-- This allows using those keys directly after the motion
						label = { exclude = "hjkliardc" },
					},
				},
			}
		end,
	},
	{
		"numToStr/Comment.nvim",
		keys = {
			{
				"gcc",
				function()
					return vim.v.count == 0
							and vim.api.nvim_replace_termcodes(
								"<Plug>(comment_toggle_linewise_current)",
								true,
								true,
								true
							)
						or vim.api.nvim_replace_termcodes("<Plug>(comment_toggle_linewise_count)", true, true, true)
				end,
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "edit: Toggle comment for line",
			},
			{
				"gbc",
				function()
					return vim.v.count == 0
							and vim.api.nvim_replace_termcodes(
								"<Plug>(comment_toggle_blockwise_current)",
								true,
								true,
								true
							)
						or vim.api.nvim_replace_termcodes("<Plug>(comment_toggle_blockwise_count)", true, true, true)
				end,
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "edit: Toggle comment for block",
			},
			{
				"gc",
				"<Plug>(comment_toggle_linewise)",
				silent = true,
				desc = "edit: Toggle comment for line with operator",
			},
			{
				"gb",
				"<Plug>(comment_toggle_blockwise)",
				silent = true,
				desc = "edit: Toggle comment for block with operator",
			},
			{
				"gc",
				"<Plug>(comment_toggle_linewise_visual)",
				mode = "x",
				silent = true,
				desc = "edit: Toggle comment for line with selection",
			},
			{
				"gb",
				"<Plug>(comment_toggle_blockwise_visual)",
				mode = "x",
				silent = true,
				desc = "edit: Toggle comment for block with selection",
			},
		},
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "Comment",
		opts = function()
			return {
				ignore = "^$",
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	{
		"sindrets/diffview.nvim",
		keys = {
			{ "<leader>gd", ":DiffviewOpen<CR>", silent = true, desc = "git: Show diff" },
			{ "<leader>gD", ":DiffviewClose<CR>", silent = true, desc = "git: Close diff" },
		},
		lazy = true,
		cmd = { "DiffviewOpen", "DiffviewClose" },
		main = "diffview",
		opts = {
			diff_binaries = false,
			enhanced_diff_hl = false,
			use_icons = true,
			show_help_hints = true,
			watch_index = true,
			git_cmd = { "git" },
			hg_cmd = { "hg" },
			view = {
				-- Config for changed files, and staged files in diff views.
				default = {
					layout = "diff2_horizontal",
					disable_diagnostics = true,
					winbar_info = false,
				},
				-- Config for conflicted files in diff views during a merge or rebase.
				merge_tool = {
					layout = "diff3_horizontal",
					disable_diagnostics = true,
					winbar_info = true,
				},
				-- Config for changed files in file history views.
				file_history = {
					layout = "diff2_horizontal",
					disable_diagnostics = true,
					winbar_info = false,
				},
			},
		},
	},
	{
		"echasnovski/mini.align",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "mini.align",
		opts = {
			silent = true,
			mappings = {
				start = "gea",
				start_with_preview = "geA",
			},
		},
	},
	{
		"echasnovski/mini.cursorword",
		lazy = true,
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = function()
			require("mini.cursorword").setup({
				-- Delay (in ms) between when cursor moved and when highlighting appeared
				delay = 200,
			})
			require("util.colors").gen_cursorword_hl()
		end,
	},
	{
		"smoka7/hop.nvim",
		keys = {
			{ "<leader>w", "<Cmd>HopWordMW<CR>", mode = { "n", "v" }, desc = "jump: Goto word" },
			{ "<leader>j", "<Cmd>HopLineMW<CR>", mode = { "n", "v" }, desc = "jump: Goto line" },
			{ "<leader>k", "<Cmd>HopLineMW<CR>", mode = { "n", "v" }, desc = "jump: Goto line" },
			{ "<leader>c", "<Cmd>HopChar1MW<CR>", mode = { "n", "v" }, desc = "jump: Goto one char" },
			{ "<leader>C", "<Cmd>HopChar2MW<CR>", mode = { "n", "v" }, desc = "jump: Goto two chars" },
		},
		lazy = true,
		version = "*",
		event = { "CursorHold", "CursorHoldI" },
		main = "hop",
		opts = { keys = "etovxqpdygfblzhckisuran" },
	},
	{
		"brenoprata10/nvim-highlight-colors",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "nvim-highlight-colors",
		opts = {
			render = "background",
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = true,
			enable_var_usage = true,
			enable_named_colors = false,
			enable_tailwind = false,
			-- Exclude filetypes or buftypes from highlighting
			exclude_filetypes = {
				"alpha",
				"dap-repl",
				"fugitive",
				"git",
				"notify",
				"NvimTree",
				"Outline",
				"TelescopePrompt",
				"toggleterm",
				"undotree",
			},
			exclude_buftypes = {
				"nofile",
				"prompt",
				"terminal",
			},
		},
	},
	{ "romainl/vim-cool", lazy = true, event = { "CursorMoved", "InsertEnter" } },
	{
		"lambdalisue/suda.vim",
		keys = {
			{ "<A-s>", ":<C-u>SudaWrite<CR>", silent = true, desc = "editn: Save file using sudo" },
		},
		lazy = true,
		cmd = { "SudaRead", "SudaWrite" },
		init = function()
			vim.g["suda#prompt"] = "Enter administrator password: "
		end,
	},
	{ "tpope/vim-sleuth", lazy = true, event = { "BufNewFile", "BufReadPost", "BufFilePost" } },
	{
		"MagicDuck/grug-far.nvim",
		keys = {
			{
				"<leader>Ss",
				function()
					require("grug-far").open()
				end,
				silent = true,
				desc = "editn: Toggle search & replace panel",
			},
			{
				"<leader>Sp",
				function()
					require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
				end,
				silent = true,
				desc = "editn: search&replace current word (project)",
			},
			{
				"<leader>Sp",
				function()
					require("grug-far").with_visual_selection()
				end,
				mode = "v",
				silent = true,
				desc = "edit: search & replace current word (project)",
			},
			{
				"<leader>Sf",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
				end,
				silent = true,
				desc = "editn: search & replace current word (file)",
			},
		},
		lazy = true,
		cmd = "GrugFar",
		main = "grug-far",
		opts = {
			engine = "ripgrep",
			engines = {
				ripgrep = {
					path = "rg",
					showReplaceDiff = true,
					placeholders = {
						enabled = true,
					},
				},
			},
			transient = true,
			icons = { enabled = true },
			disableBufferLineNumbers = true,
			windowCreationCommand = "bot split",
			keymaps = {
				replace = { n = ",r" },
				qflist = { n = ",q" },
				syncLocations = { n = ",s" },
				syncLine = { n = ",l" },
				close = { n = ",c" },
				historyOpen = { n = ",t" },
				historyAdd = { n = ",a" },
				refresh = { n = ",f" },
				openLocation = { n = ",o" },
				openNextLocation = { n = "<Down>" },
				openPrevLocation = { n = "<Up>" },
				gotoLocation = { n = "<Enter>" },
				pickHistoryEntry = { n = "<Enter>" },
				abort = { n = ",b" },
				help = { n = "g?" },
				toggleShowCommand = { n = ",w" },
				swapEngine = { n = ",e" },
				previewLocation = { n = ",i" },
				swapReplacementInterpreter = { n = ",x" },
				applyNext = { n = ",j" },
				applyPrev = { n = ",k" },
				syncNext = { n = ",n" },
				syncPrev = { n = ",p" },
				syncFile = { n = ",v" },
				nextInput = { n = "<Tab>" },
				prevInput = { n = "<S-Tab>" },
			},
		},
	},
}
