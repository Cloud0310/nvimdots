return {
	"akinsho/bufferline.nvim",
	keys = {
		{ "<A-i>", ":BufferLineCycleNext<CR>", silent = true, desc = "buffer: Switch to next" },
		{ "<A-o>", ":BufferLineCyclePrev<CR>", silent = true, desc = "buffer: Switch to prev" },
		{ "<A-S-i>", ":BufferLineMoveNext<CR>", silent = true, desc = "buffer: Move current to next" },
		{ "<A-S-o>", ":BufferLineMovePrev<CR>", silent = true, desc = "buffer: Move current to prev" },
		{ "<leader>be", ":BufferLineSortByExtension<CR>", desc = "buffer: Sort by extension" },
		{ "<leader>bd", ":BufferLineSortByDirectory<CR>", desc = "buffer: Sort by directory" },
		{ "<A-1>", ":BufferLineGoToBuffer 1<CR>", silent = true, desc = "buffer: Goto buffer 1" },
		{ "<A-2>", ":BufferLineGoToBuffer 2<CR>", silent = true, desc = "buffer: Goto buffer 2" },
		{ "<A-3>", ":BufferLineGoToBuffer 3<CR>", silent = true, desc = "buffer: Goto buffer 3" },
		{ "<A-4>", ":BufferLineGoToBuffer 4<CR>", silent = true, desc = "buffer: Goto buffer 4" },
		{ "<A-5>", ":BufferLineGoToBuffer 5<CR>", silent = true, desc = "buffer: Goto buffer 5" },
		{ "<A-6>", ":BufferLineGoToBuffer 6<CR>", silent = true, desc = "buffer: Goto buffer 6" },
		{ "<A-7>", ":BufferLineGoToBuffer 7<CR>", silent = true, desc = "buffer: Goto buffer 7" },
		{ "<A-8>", ":BufferLineGoToBuffer 8<CR>", silent = true, desc = "buffer: Goto buffer 8" },
		{ "<A-9>", ":BufferLineGoToBuffer 9<CR>", silent = true, desc = "buffer: Goto buffer 9" },
	},
	lazy = true,
	event = { "BufReadPre", "BufAdd", "BufNewFile" },
	main = "bufferline",
	opts = function()
		local icons = { ui = require("util.icons").get("ui") }

		local opts = {
			options = {
				always_show_bufferline = true,
				close_command = "BufDel! %d",
				right_mouse_command = "BufDel! %d",
				tab_size = 20,
				separator_style = "thin",
				show_buffer_icons = true,
				show_tab_indicators = true,
				show_buffer_close_icons = true,
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count)
					return "(" .. count .. ")"
				end,
				numbers = nil,
				max_name_length = 20,
				max_prefix_length = 13,
				buffer_close_icon = icons.ui.Close,
				left_trunc_marker = icons.ui.Left,
				right_trunc_marker = icons.ui.Right,
				modified_icon = icons.ui.Modified_alt,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						padding = 0,
					},
					{
						filetype = "trouble",
						text = "LSP Outline",
						text_align = "center",
						padding = 0,
					},
				},
			},
			-- Change bufferline's highlights here! See `:h bufferline-highlights` for detailed explanation.
			-- Note: If you use catppuccin then modify the colors below!
			highlights = {},
		}

		if (vim.g.colors_name or ""):find("catppuccin") then
			local cp = require("util.colors").get_palette() -- Get the palette.

			local catppuccin_hl_overwrite = {
				highlights = require("catppuccin.groups.integrations.bufferline").get({
					styles = { "italic", "bold" },
					custom = {
						all = {
							-- Hint
							hint = { fg = cp.rosewater },
							hint_visible = { fg = cp.rosewater },
							hint_selected = { fg = cp.rosewater },
							hint_diagnostic = { fg = cp.rosewater },
							hint_diagnostic_visible = { fg = cp.rosewater },
							hint_diagnostic_selected = { fg = cp.rosewater },
						},
					},
				}),
			}

			opts = vim.tbl_deep_extend("force", opts, catppuccin_hl_overwrite)
		end
		return opts
	end,
}
