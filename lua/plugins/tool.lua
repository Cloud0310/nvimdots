local settings = require("config.settings")

return {
	{
		"tpope/vim-fugitive",
		keys = {
			{ "gps", ":G push<CR>", silent = true, desc = "git: Push" },
			{ "gpl", ":G pull<CR>", silent = true, desc = "git: Pull" },
			{ "<leader>gG", ":<C-u>Git<CR>", silent = true, desc = "git: Open git-fugitive" },
		},
		lazy = true,
		cmd = { "Git", "G" },
	},
	{
		"pysan3/fcitx5.nvim",
		lazy = true,
		event = "BufReadPost",
		cond = vim.fn.executable("fcitx5-remote") == 1,
		main = "fcitx5",
		opts = {
			log = "warn",
			remember_prior = true,
			define_autocmd = true,
		},
	},
	{
		"ibhagwan/smartyank.nvim",
		lazy = true,
		event = "BufReadPost",
		main = "smartyank",
		opts = {
			-- disabled here since highlight on yank is already enabled
			highlight = { enabled = false },
			clipboard = { enabled = true },
			tmux = {
				enabled = true,
				-- remove `-w` to disable copy to host client's clipboard
				cmd = { "tmux", "set-buffer", "-w" },
			},
			osc52 = {
				enabled = true,
				ssh_only = true,
				silent = true,
				-- use tmux escape sequence, only enable if you're using tmux and have issues
				-- escseq = "tmux",
			},
			-- copy indiscriminately
			validate_yank = false,
		},
	},
	{
		"michaelb/sniprun",
		keys = {
			{ "<leader>r", ":SnipRun<CR>", mode = "v", silent = true, desc = "tool: Run code by range" },
			{ "<leader>r", ":<C-u>%SnipRun<CR>", silent = true, desc = "tool: Run code by file" },
		},
		lazy = true,
		build = "bash ./install.sh",
		cmd = { "SnipRun", "SnipReset", "SnipInfo" },
		main = "sniprun",
		opts = {
			borders = "single",
			inline_messages = 0,
			interpreter_options = {},
			display = {
				"Classic", -- "display results in the command-line area
				"VirtualTextOk", -- "display ok results as virtual text (multiline is shortened)
				"VirtualTextErr", -- "display error results as virtual text
				-- "TempFloatingWindow", -- "display results in a floating window
				"LongTempFloatingWindow", -- "same as above, but only long results. To use with VirtualText
				-- "Terminal"                 -- "display results in a vertical split
			},
		},
	},
	{
		"akinsho/toggleterm.nvim",
		keys = function()
			local lazygit
			return {
				{
					"<C-\\>",
					":ToggleTerm direction=horizontal<CR>",
					silent = true,
					desc = "terminal: Toggle horizontal",
				},
				{
					"<C-\\>",
					"<Esc><Cmd>ToggleTerm direction=horizontal<CR>",
					mode = "i",
					silent = true,
					desc = "terminal: Toggle horizontal",
				},
				{ "<C-\\>", "<Cmd>ToggleTerm<CR>", mode = "t", silent = true, desc = "terminal: Toggle horizontal" },
				{ "<A-\\>", ":ToggleTerm direction=vertical<CR>", silent = true, desc = "terminal: Toggle vertical" },
				{
					"<A-\\>",
					"<Esc><Cmd>ToggleTerm direction=vertical<CR>",
					mode = "i",
					silent = true,
					desc = "terminal: Toggle vertical",
				},
				{ "<A-\\>", "<Cmd>ToggleTerm<CR>", mode = "t", silent = true, desc = "terminal: Toggle vertical" },
				{ "<F5>", ":ToggleTerm direction=vertical<CR>", silent = true, desc = "terminal: Toggle vertical" },
				{
					"<F5>",
					"<Esc><Cmd>ToggleTerm direction=vertical<CR>",
					mode = "i",
					silent = true,
					desc = "terminal: Toggle vertical",
				},
				{ "<F5>", "<Cmd>ToggleTerm<CR>", mode = "t", silent = true, desc = "terminal: Toggle vertical" },
				{ "<A-d>", ":ToggleTerm direction=float<CR>", silent = true, desc = "terminal: Toggle float" },
				{
					"<A-d>",
					"<Esc><Cmd>ToggleTerm direction=float<CR>",
					mode = "i",
					silent = true,
					desc = "terminal: Toggle float",
				},
				{ "<A-d>", "<Cmd>ToggleTerm<CR>", mode = "t", silent = true, desc = "terminal: Toggle float" },
				{
					"<leader>gg",
					function()
						if vim.fn.executable("lazygit") == 1 then
							if not lazygit then
								lazygit = require("toggleterm.terminal").Terminal:new({
									cmd = "lazygit",
									direction = "float",
									close_on_exit = true,
									hidden = true,
								})
							end
							lazygit:toggle()
						else
							vim.notify(
								"Command [lazygit] not found!",
								vim.log.levels.ERROR,
								{ title = "toggleterm.nvim" }
							)
						end
					end,
					silent = true,
					desc = "git: Toggle lazygit",
				},
			}
		end,
		lazy = true,
		cmd = {
			"ToggleTerm",
			"ToggleTermSetName",
			"ToggleTermToggleAll",
			"ToggleTermSendVisualLines",
			"ToggleTermSendCurrentLine",
			"ToggleTermSendVisualSelection",
		},
		main = "toggleterm",
		opts = function()
			return {
				-- size can be a number or function which is passed the current terminal
				size = function(term)
					if term.direction == "horizontal" then
						return vim.o.lines * 0.30
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.35
					end
				end,
				highlights = {
					Normal = {
						link = "Normal",
					},
					NormalFloat = {
						link = "NormalFloat",
					},
					FloatBorder = {
						link = "FloatBorder",
					},
				},
				on_open = function()
					-- Prevent infinite calls from freezing neovim.
					-- Only set these options specific to this terminal buffer.
					vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
					vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
				end,
				hide_numbers = true,
				shade_terminals = false,
				start_in_insert = true,
				persist_mode = false,
				insert_mappings = true,
				persist_size = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
			}
		end,
	},
	{
		"folke/trouble.nvim",
		keys = {
			{ "gt", ":Trouble diagnostics toggle<CR>", silent = true, desc = "lsp: Toggle trouble list" },
			{
				"<leader>lw",
				":Trouble diagnostics toggle<CR>",
				silent = true,
				desc = "lsp: Show workspace diagnostics",
			},
			{
				"<leader>lp",
				":Trouble project_diagnostics toggle<CR>",
				silent = true,
				desc = "lsp: Show project diagnostics",
			},
			{
				"<leader>ld",
				":Trouble diagnostics toggle filter.buf=0<CR>",
				silent = true,
				desc = "lsp: Show document diagnostics",
			},
		},
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		main = "trouble",
		opts = function()
			local icons = {
				ui = require("util.icons").get("ui", true),
			}
			return {
				auto_open = false,
				auto_close = false,
				auto_jump = false,
				auto_preview = true,
				auto_refresh = true,
				focus = false, -- do not focus the window when opened
				follow = true,
				restore = true,
				icons = {
					indent = {
						fold_open = icons.ui.ArrowOpen,
						fold_closed = icons.ui.ArrowClosed,
					},
					folder_closed = icons.ui.Folder,
					folder_open = icons.ui.FolderOpen,
				},
				modes = {
					project_diagnostics = {
						mode = "diagnostics",
						filter = {
							any = {
								{
									function(item)
										return item.filename:find(vim.uv.cwd(), 1, true)
									end,
								},
							},
						},
					},
				},
			}
		end,
	},
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		main = "which-key",
		opts = function()
			local icons = {
				ui = require("util.icons").get("ui"),
				misc = require("util.icons").get("misc"),
				git = require("util.icons").get("git", true),
				cmp = require("util.icons").get("cmp", true),
				aichat = require("util.icons").get("aichat", true),
			}
			return {
				preset = "classic",
				delay = vim.o.timeoutlen,
				triggers = {
					{ "<auto>", mode = "nixso" },
				},
				plugins = {
					marks = true,
					registers = true,
					spelling = {
						enabled = true,
						suggestions = 20,
					},
					presets = {
						motions = false,
						operators = false,
						text_objects = true,
						windows = true,
						nav = true,
						z = true,
						g = true,
					},
				},
				win = {
					border = "none",
					padding = { 1, 2 },
					wo = { winblend = 0 },
				},
				expand = 1,
				icons = {
					group = "",
					rules = false,
					colors = false,
					breadcrumb = icons.ui.Separator,
					separator = icons.misc.Vbar,
					keys = {
						C = "C-",
						M = "A-",
						S = "S-",
						BS = "<BS> ",
						CR = "<CR> ",
						NL = "<NL> ",
						Esc = "<Esc> ",
						Tab = "<Tab> ",
						Up = "<Up> ",
						Down = "<Down> ",
						Left = "<Left> ",
						Right = "<Right> ",
						Space = "<Space> ",
						ScrollWheelUp = "<ScrollWheelUp> ",
						ScrollWheelDown = "<ScrollWheelDown> ",
					},
				},
				spec = {
					{ "<leader>g", group = icons.git.Git .. "Git" },
					{ "<leader>d", group = icons.ui.Bug .. " Debug" },
					{ "<leader>T", group = "Tests" },
					{ "<leader>s", group = icons.cmp.tmux .. "Session" },
					{ "<leader>b", group = icons.ui.Buffer .. " Buffer" },
					{ "<leader>S", group = icons.ui.Search .. " Search" },
					{ "<leader>W", group = icons.ui.Window .. " Window" },
					{ "<leader>p", group = icons.ui.Package .. " Package" },
					{ "<leader>l", group = icons.misc.LspAvailable .. " Lsp" },
					{ "<leader>f", group = icons.ui.Telescope .. " Fuzzy Find" },
					{ "<leader>n", group = icons.ui.FolderOpen .. " Nvim Tree" },
					{ "<leader>c", group = icons.aichat.Chat .. " Chat" },
				},
			}
		end,
	},
	{
		"ibhagwan/fzf-lua",
		keys = function()
			if require("config.settings").search_backend == "fzf" then
				return {
					{
						"<leader>fs",
						function()
							local is_config = vim.uv.cwd() == require("config.paths").vim_path
							if require("config.settings").search_backend == "fzf" then
								require("fzf-lua").grep_project({
									search = require("fzf-lua.utils").get_visual_selection(),
									rg_opts = "--column --line-number --no-heading --color=always --smart-case"
										.. (is_config and " --no-ignore --hidden --glob '!.git/*'" or ""),
								})
							else
								require("telescope-live-grep-args.shortcuts").grep_visual_selection(
									is_config and { additional_args = { "--no-ignore" } } or {}
								)
							end
						end,
						mode = "v",
						silent = true,
						desc = "tool: Find word under cursor",
					},
					{
						"<leader>fR",
						function()
							if require("config.settings").search_backend == "fzf" then
								require("fzf-lua").resume()
							end
						end,
						silent = true,
						desc = "tool: Resume last search",
					},
				}
			end
			return {}
		end,
		lazy = true,
		cond = settings.search_backend == "fzf",
		cmd = "FzfLua",
		main = "fzf-lua",
		opts = function()
			local icons = { ui = require("util.icons").get("ui", true) }
			return {
				{ "skim", "telescope" },
				defaults = {
					prompt = icons.ui.Telescope .. " ",
				},
			}
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}
