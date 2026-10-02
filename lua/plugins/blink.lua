local settings = require("config.settings")
local edit_prediction_source = settings.edit_prediction_source
local use_copilot_prediction = settings.use_copilot and edit_prediction_source == "copilot"
local use_minuet_prediction = edit_prediction_source == "oai-compatible"

return {
	"saghen/blink.cmp",
	lazy = true,
	version = "1.*",
	event = { "VeryLazy", "InsertEnter", "CmdlineEnter" },
	main = "blink.cmp",
	opts = function()
		local icons = {
			kind = require("util.icons").get("kind"),
			type = require("util.icons").get("type"),
			cmp = require("util.icons").get("cmp"),
		}

		local source_labels = {
			copilot = "[CPLT]",
			minuet = "[AI]",
			buffer = "[BUF]",
			lazydev = "[LAZY]",
			lsp = "[LSP]",
			path = "[PATH]",
			ripgrep = "[RG]",
			tmux = "[TMUX]",
			latex_symbols = "[LTEX]",
			snippets = "[SNIP]",
			spell = "[SPELL]",
		}

		local sources_default = { "lazydev", "lsp", "snippets", "path", "buffer", "spell", "tmux", "latex_symbols" }
		if use_copilot_prediction then
			table.insert(sources_default, 1, "copilot")
		end
		if use_minuet_prediction then
			table.insert(sources_default, 1, "minuet")
		end

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		return {
			snippets = { preset = "luasnip" },
			cmdline = {
				enabled = true,
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" or type == "@" then
						return { "cmdline", "path" }
					end
					return {}
				end,
				completion = {
					list = { selection = { preselect = true, auto_insert = true } },
					menu = {
						auto_show = true,
						draw = {
							columns = {
								{ "label", "label_description", gap = 1 },
								{ "kind_icon", "kind", gap = 1 },
								{ "source_name" },
							},
						},
					},
					ghost_text = { enabled = false },
				},
			},
			term = { enabled = false },
			appearance = { nerd_font_variant = "normal" },
			fuzzy = { implementation = "prefer_rust_with_warning" },

			sources = {
				default = sources_default,
				providers = {
					lsp = { max_items = 350 },
					minuet = {
						name = "Minuet",
						module = "minuet.blink",
						async = true,
						timeout_ms = 3000,
						score_offset = 100,
					},
					lazydev = {
						module = "lazydev.integrations.blink",
						name = "LazyDev",
						score_offset = 100,
						enabled = function()
							return vim.bo.filetype == "lua"
						end,
					},
					buffer = {
						opts = {
							get_bufnrs = function()
								return vim.api.nvim_buf_line_count(0) < 15000 and vim.api.nvim_list_bufs() or {}
							end,
						},
					},
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						async = true,
						enabled = function()
							local name = vim.api.nvim_buf_get_name(0)
							return vim.bo.buftype == ""
								and not vim.startswith(name, vim.fn.expand("~/Documents/remotes/"))
						end,
						opts = {
							prefix_min_len = 4,
							project_root_marker = { ".git", ".rg-root" },
							backend = {
								-- The mixed backend loses the search cancellation callback.
								use = "ripgrep",
								context_size = 3,
								ripgrep = {
									project_root_fallback = false,
									ignore_paths = { vim.fn.expand("~"), "/" },
									max_filesize = "200K",
									additional_rg_options = {
										"--max-count=5",
										"--threads=2",
										"--one-file-system",
										"--glob=!**/node_modules/**",
										"--glob=!**/target/**",
									},
								},
							},
						},
						score_offset = -15,
						max_items = 3,
					},
					copilot = {
						name = "Copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
						opts = {
							max_completions = 3,
							max_attempts = 4,
						},
					},
					spell = {
						name = "Spell",
						module = "blink.compat.source",
						opts = { cmp_name = "spell" },
					},
					tmux = {
						name = "Tmux",
						module = "blink.compat.source",
						opts = { cmp_name = "tmux" },
					},
					latex_symbols = {
						name = "LaTeX",
						module = "blink.compat.source",
						opts = { cmp_name = "latex_symbols" },
					},
				},
			},

			keymap = {
				preset = "none",
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<C-d>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-w>"] = { "cancel", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},

			completion = {
				keyword = {
					range = "full",
				},
				accept = {
					auto_brackets = {
						enabled = true,
						kind_resolution = {
							enabled = true,
						},
						semantic_token_resolution = {
							enabled = true,
							blocked_filetypes = { "java" },
						},
					},
				},
				ghost_text = { enabled = false },
				list = {
					max_items = 120,
					selection = { preselect = false, auto_insert = false },
				},
				menu = {
					border = "single",
					winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:PmenuSel",
					scrollbar = false,
					draw = {
						padding = { 1, 1 },
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon" },
							{ "kind", "source_name", gap = 1 },
						},
						components = {
							kind_icon = {
								text = function(ctx)
									local lspkind_icons =
										vim.tbl_deep_extend("force", icons.kind, icons.type, icons.cmp)
									return icons.cmp[ctx.source_id] or lspkind_icons[ctx.kind] or icons.cmp.undefined
								end,
							},
							kind = {
								text = function(ctx)
									return ctx.kind or ""
								end,
								highlight = function(ctx)
									return ctx.kind
								end,
							},
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
							source_name = {
								text = function(ctx)
									return source_labels[ctx.source_id] or "[BTN]"
								end,
								highlight = "Comment",
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					treesitter_highlighting = true,
					window = {
						border = "single",
						winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
					},
				},
			},
			signature = {
				enabled = true,
				trigger = {
					show_on_insert = true,
				},
				window = {
					border = "single",
					treesitter_highlighting = true,
					show_documentation = true,
				},
			},
		}
	end,
	dependencies = {
		{ "saghen/blink.compat", version = "2.*", opts = {} },
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			config = function()
				local vim_path = require("config.paths").vim_path
				local snippet_path = vim_path .. "/snips/"

				require("luasnip").setup({
					history = true,
					update_events = "TextChanged,TextChangedI",
					delete_check_events = "TextChanged,InsertLeave",
				})

				require("luasnip.loaders.from_vscode").lazy_load({
					paths = {
						snippet_path,
					},
				})
				require("luasnip.loaders.from_lua").lazy_load()
				require("luasnip.loaders.from_vscode").lazy_load()
				require("luasnip.loaders.from_snipmate").lazy_load()
			end,
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
			main = "minuet",
			opts = function()
				local prediction = require("util.ai").get_prediction_config()
				if not prediction then
					vim.notify(
						"Minuet prediction requires `pred_adapter` to reference an OpenAI-compatible or FIM-compatible entry in `ai_adapters`.",
						vim.log.levels.ERROR,
						{ title = "minuet-ai.nvim" }
					)
					return
				end

				local provider = prediction.provider
				return {
					provider = provider,
					n_completions = provider == "openai_fim_compatible" and 1 or nil,
					provider_options = {
						[provider] = {
							api_key = prediction.api_key,
							end_point = prediction.end_point,
							model = prediction.model,
							name = prediction.name,
							optional = prediction.optional,
						},
					},
				}
			end,
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
					config = function()
						vim.defer_fn(function()
							require("copilot").setup({
								panel = {
									-- if true, it can interfere with completions in blink-copilot
									enabled = false,
								},
								suggestion = {
									-- if true, it can interfere with completions in blink-copilot
									enabled = false,
								},
								filetypes = {
									["dap-repl"] = false,
									["fugitive"] = false,
									["fugitiveblame"] = false,
									["git"] = false,
									["gitcommit"] = false,
									["log"] = false,
									["toggleterm"] = false,
								},
							})
						end, 100)
					end,
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
