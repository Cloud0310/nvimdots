return {
	"Saecki/crates.nvim",
	lazy = true,
	event = "BufReadPost Cargo.toml",
	config = function()
		local icons = {
			diagnostics = require("util.icons").get("diagnostics", true),
			git = require("util.icons").get("git", true),
			misc = require("util.icons").get("misc", true),
			ui = require("util.icons").get("ui", true),
			kind = require("util.icons").get("kind", true),
		}

		require("crates").setup({
			smart_insert = true,
			insert_closing_quote = true,
			autoload = true,
			autoupdate = true,
			autoupdate_throttle = 250,
			loading_indicator = true,
			date_format = "%Y-%m-%d",
			thousands_separator = ",",
			notification_title = "Crates",
			curl_args = { "-sL", "--retry", "1" },
			text = {
				loading = " " .. icons.misc.Watch .. "Loading",
				version = " " .. icons.ui.Check .. "%s",
				prerelease = " " .. icons.diagnostics.Warning_alt .. "%s",
				yanked = " " .. icons.diagnostics.Error .. "%s",
				nomatch = " " .. icons.diagnostics.Question .. "No match",
				upgrade = " " .. icons.diagnostics.Hint_alt .. "%s",
				error = " " .. icons.diagnostics.Error .. "Error fetching crate",
			},
			popup = {
				autofocus = false,
				hide_on_select = true,
				copy_register = '"',
				style = "minimal",
				border = "rounded",
				show_version_date = true,
				show_dependency_version = true,
				max_height = 30,
				min_width = 20,
				padding = 1,
				text = {
					title = icons.ui.Package .. "%s",
					description = "%s",
					created_label = icons.misc.Added .. "created" .. "        ",
					created = "%s",
					updated_label = icons.misc.ManUp .. "updated" .. "        ",
					updated = "%s",
					downloads_label = icons.ui.CloudDownload .. "downloads      ",
					downloads = "%s",
					homepage_label = icons.misc.Campass .. "homepage       ",
					homepage = "%s",
					repository_label = icons.git.Repo .. "repository     ",
					repository = "%s",
					documentation_label = icons.diagnostics.Information_alt .. "documentation  ",
					documentation = "%s",
					crates_io_label = icons.ui.Package .. "crates.io      ",
					crates_io = "%s",
					categories_label = icons.kind.Class .. "categories     ",
					keywords_label = icons.kind.Keyword .. "keywords       ",
					version = "  %s",
					prerelease = icons.diagnostics.Warning_alt .. "%s prerelease",
					yanked = icons.diagnostics.Error .. "%s yanked",
					version_date = "  %s",
					feature = "  %s",
					enabled = icons.ui.Play .. "%s",
					transitive = icons.ui.List .. "%s",
					normal_dependencies_title = icons.kind.Interface .. "Dependencies",
					build_dependencies_title = icons.misc.Gavel .. "Build dependencies",
					dev_dependencies_title = icons.misc.Glass .. "Dev dependencies",
					dependency = "  %s",
					optional = icons.ui.BigUnfilledCircle .. "%s",
					dependency_version = "  %s",
					loading = " " .. icons.misc.Watch,
				},
			},
			completion = {
				insert_closing_quote = true,
				text = {
					prerelease = " " .. icons.diagnostics.Warning_alt .. "pre-release ",
					yanked = " " .. icons.diagnostics.Error_alt .. "yanked ",
				},
			},
		})

		-- Set buffer-local keymaps
		local crates = require("crates")
		vim.keymap.set("n", "<leader>ct", function()
			crates.toggle()
		end, { silent = true, buffer = 0, desc = "crates: Toggle spec activities" })

		vim.keymap.set("n", "<leader>cr", function()
			crates.reload()
		end, { silent = true, buffer = 0, desc = "crates: Reload crate specs" })

		vim.keymap.set("n", "<leader>cs", function()
			crates.show_popup()
		end, { silent = true, buffer = 0, desc = "crates: Toggle pop-up window" })

		vim.keymap.set("n", "<leader>cv", function()
			crates.show_versions_popup()
			crates.show_popup()
		end, { silent = true, buffer = 0, desc = "crates: Select spec versions" })

		vim.keymap.set("n", "<leader>cf", function()
			crates.show_features_popup()
			crates.show_popup()
		end, { silent = true, buffer = 0, desc = "crates: Select spec features" })

		vim.keymap.set("n", "<leader>cd", function()
			crates.show_dependencies_popup()
			crates.show_popup()
		end, { silent = true, buffer = 0, desc = "crates: Show project dependencies" })

		vim.keymap.set("n", "<leader>cu", function()
			crates.update_crate()
		end, { silent = true, buffer = 0, desc = "crates: Update current crate's spec" })

		vim.keymap.set("v", "<leader>cu", function()
			crates.update_crates()
		end, { silent = true, buffer = 0, desc = "crates: Update selected crate's spec" })

		vim.keymap.set("n", "<leader>ca", function()
			crates.update_all_crates()
		end, { silent = true, buffer = 0, desc = "crates: Update all crates' specs" })

		vim.keymap.set("n", "<leader>cU", function()
			crates.upgrade_crate()
		end, { silent = true, buffer = 0, desc = "crates: Upgrade current crate" })

		vim.keymap.set("v", "<leader>cU", function()
			crates.upgrade_crates()
		end, { silent = true, buffer = 0, desc = "crates: Upgrade selected crates" })

		vim.keymap.set("n", "<leader>cA", function()
			crates.upgrade_all_crates()
		end, { silent = true, buffer = 0, desc = "crates: Upgrade all crates" })

		vim.keymap.set("n", "<leader>cH", function()
			crates.open_homepage()
		end, { silent = true, buffer = 0, desc = "crates: Open current crate's homepage" })

		vim.keymap.set("n", "<leader>cR", function()
			crates.open_repository()
		end, { silent = true, buffer = 0, desc = "crates: Open current crate's repository" })

		vim.keymap.set("n", "<leader>cD", function()
			crates.open_documentation()
		end, { silent = true, buffer = 0, desc = "crates: Open current crate's documentation" })

		vim.keymap.set("n", "<leader>cC", function()
			crates.open_crates_io()
		end, { silent = true, buffer = 0, desc = "crates: Browse current crate on crates.io" })
	end,
	dependencies = "nvim-lua/plenary.nvim",
}
