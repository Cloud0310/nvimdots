return {
	{
		"mason-org/mason.nvim",
		lazy = true,
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonUpdate", "MasonLog" },
		main = "mason",
		opts = function()
			local icons = {
				ui = require("util.icons").get("ui", true),
				misc = require("util.icons").get("misc", true),
			}
			return {
				ui = {
					border = "single",
					icons = {
						package_pending = icons.ui.Modified_alt,
						package_installed = icons.ui.Check,
						package_uninstalled = icons.misc.Ghost,
					},
					keymaps = {
						toggle_server_expand = "<CR>",
						install_server = "i",
						update_server = "u",
						check_server_version = "c",
						update_all_servers = "U",
						check_outdated_servers = "C",
						uninstall_server = "X",
						cancel_installation = "<C-c>",
					},
				},
			}
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- Register its VimEnter installation check before startup finishes.
		lazy = false,
		dependencies = { "mason-org/mason.nvim" },
		main = "mason-tool-installer",
		opts = function()
			return {
				ensure_installed = require("config.settings").mason_tools,
				auto_update = false,
				run_on_start = true,
				start_delay = 3000,
				-- Use Mason package names and avoid pulling LSP/DAP plugins into startup.
				integrations = {
					["mason-lspconfig"] = false,
					["mason-null-ls"] = false,
					["mason-nvim-dap"] = false,
				},
			}
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			local null_ls = require("null-ls")
			-- Diagnostics only. Conform owns all external formatting; Mason tools are installed separately.
			local sources = { null_ls.builtins.diagnostics.vint }
			require("null-ls").setup({
				border = "rounded",
				debug = false,
				log_level = "warn",
				update_in_insert = false,
				sources = sources,
				default_timeout = require("config.settings").format_timeout,
			})

			-- Setup usercmd to register/deregister available source(s)
			local function _gen_completion()
				local sources_cont = null_ls.get_source({
					filetype = vim.bo.filetype,
				})
				local completion_items = {}
				for _, server in pairs(sources_cont) do
					table.insert(completion_items, server.name)
				end
				return completion_items
			end
			vim.api.nvim_create_user_command("NullLsToggle", function(opts)
				if vim.tbl_contains(_gen_completion(), opts.args) then
					null_ls.toggle({ name = opts.args })
				else
					vim.notify(
						string.format("[Null-ls] Unable to find any registered source named [%s].", opts.args),
						vim.log.levels.ERROR,
						{ title = "Null-ls Internal Error" }
					)
				end
			end, {
				nargs = 1,
				complete = _gen_completion,
			})
		end,
		dependencies = { "nvim-lua/plenary.nvim", "mason-org/mason.nvim" },
	},
	{
		"folke/lazydev.nvim",
		lazy = true,
		ft = "lua",
		main = "lazydev",
		opts = {
			library = {
				"lazy.nvim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
}
