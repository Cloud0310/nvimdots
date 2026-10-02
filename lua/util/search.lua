local M = {}

M.telescope_collections = function(opts)
	local tabs = require("search.tabs")
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local collections = vim.tbl_keys(tabs.collections)

	-- build and launch picker
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Telescope Collections",
			finder = finders.new_table({ results = collections }),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(bufnr)
				actions.select_default:replace(function()
					actions.close(bufnr)
					local selection = state.get_selected_entry()
					require("search").open({ collection = selection[1] })
				end)
				return true
			end,
		})
		:find()
end

M.picker = function(method, tele_opts)
	local prompt_position = require("telescope.config").values.layout_config.horizontal.prompt_position
	local fzf_opts = { ["--layout"] = prompt_position == "top" and "reverse" or "default" }
	if require("config.settings").search_backend == "fzf" then
		require("fzf-lua")[method]({
			fzf_opts = fzf_opts,
		})
	else
		require("telescope.builtin")[method](tele_opts)
	end
end

return M
