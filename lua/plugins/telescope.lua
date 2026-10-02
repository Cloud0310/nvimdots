return {
	"nvim-telescope/telescope.nvim",
	keys = function()
		local keys = {
			{
				"<C-p>",
				function()
					require("util.search").picker("keymaps", {
						lhs_filter = function(lhs)
							return not string.find(lhs, "Þ")
						end,
					})
				end,
				silent = true,
				desc = "tool: Toggle command panel",
			},
			{
				"<leader>fc",
				function()
					require("util.search").telescope_collections(require("telescope.themes").get_dropdown())
				end,
				silent = true,
				desc = "tool: Open Telescope collections",
			},
			{
				"<leader>ff",
				function()
					require("search").open({ collection = "file" })
				end,
				silent = true,
				desc = "tool: Find files",
			},
			{
				"<leader>fp",
				function()
					require("search").open({ collection = "pattern" })
				end,
				silent = true,
				desc = "tool: Find patterns",
			},
			{
				"<leader>fg",
				function()
					require("search").open({ collection = "git" })
				end,
				silent = true,
				desc = "tool: Locate Git objects",
			},
			{
				"<leader>fd",
				function()
					require("search").open({ collection = "dossier" })
				end,
				silent = true,
				desc = "tool: Retrieve dossiers",
			},
			{
				"<leader>fm",
				function()
					require("search").open({ collection = "misc" })
				end,
				silent = true,
				desc = "tool: Miscellaneous",
			},
			{ "<leader>fr", ":Telescope resume<CR>", silent = true, desc = "tool: Resume last search" },
		}
		if require("config.settings").search_backend ~= "fzf" then
			vim.list_extend(keys, {
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
			})
		end
		return keys
	end,
	lazy = true,
	cmd = "Telescope",
	config = function()
		local icons = { ui = require("util.icons").get("ui", true) }
		local lga_actions = require("telescope-live-grep-args.actions")

		require("telescope").setup({
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				initial_mode = "insert",
				prompt_prefix = " " .. icons.ui.Telescope .. " ",
				selection_caret = icons.ui.ChevronRight,
				scroll_strategy = "limit",
				results_title = false,
				layout_strategy = "flex",
				path_display = { "absolute" },
				selection_strategy = "reset",
				color_devicons = true,
				file_ignore_patterns = { ".git/", ".cache", "build/", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip" },
				layout_config = {
					horizontal = {
						preview_width = 0.55,
					},
					vertical = {
						mirror = false,
					},
					width = 0.85,
					height = 0.92,
					preview_cutoff = 120,
				},
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
			},
			extensions = {
				fzf = {
					fuzzy = false,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				frecency = {
					show_scores = true,
					show_unindexed = true,
					ignore_patterns = { "*.git/*", "*/tmp/*" },
				},
				live_grep_args = {
					auto_quoting = true, -- enable/disable auto-quoting
					mappings = { -- extend mappings
						i = {
							["<C-k>"] = lga_actions.quote_prompt(),
							["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
						},
					},
				},
				undo = {
					side_by_side = true,
					mappings = {
						i = {
							["<cr>"] = require("telescope-undo.actions").yank_additions,
							["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
							["<C-cr>"] = require("telescope-undo.actions").restore,
						},
					},
				},
				advanced_git_search = {
					diff_plugin = "diffview",
					git_flags = { "-c", "delta.side-by-side=true" },
					entry_default_author_or_date = "author", -- one of "author" or "date"
				},
			},
		})

		require("telescope").load_extension("frecency")
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("live_grep_args")
		require("telescope").load_extension("notify")
		require("telescope").load_extension("projects")
		require("telescope").load_extension("undo")
		require("telescope").load_extension("zoxide")
		require("telescope").load_extension("persisted")
		require("telescope").load_extension("advanced_git_search")
	end,
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "jvgrootveld/telescope-zoxide" },
		{ "debugloop/telescope-undo.nvim" },
		{ "nvim-telescope/telescope-frecency.nvim" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{
			"ayamir/search.nvim",
			main = "search",
			opts = function()
				local vim_path = require("config.paths").vim_path
				local search_backend = require("config.settings").search_backend
				local use_fzf = search_backend == "fzf"
				local fzf = use_fzf and require("fzf-lua")
				local extensions = require("telescope").extensions
				local builtins = require("telescope.builtin")
				local prompt_pos = require("telescope.config").values.layout_config.horizontal.prompt_position

				local base_opts = use_fzf
						and { fzf_opts = { ["--layout"] = (prompt_pos == "top" and "reverse" or "default") } }
					or {}

				---Returns current directory and whether it's a Git repo root
				---@return string @Current working directory
				---@return boolean|nil @true if `.git` folder exists here, false if `.git` exists but isn't folder, nil if `.git` missing
				local function get_root_info()
					local cwd = vim.uv.cwd()
					local stat = vim.uv.fs_stat(".git")
					return cwd, stat and stat.type == "directory"
				end

				---Creates a file search function based on backend and context
				---@param fzf_fn string @Name of the fzf-lua function to call (e.g. "files")
				---@param tb_fn function @Telescope builtin function to call (e.g. `builtin.find_files`)
				---@param git_only boolean @Whether to restrict search to git tracked files only
				---@return fun():any @A function that executes the selected search with proper options
				local function file_searcher(fzf_fn, tb_fn, git_only)
					return function()
						local cwd, is_git = get_root_info()
						local opts = vim.deepcopy(base_opts, true)
						if cwd == vim_path then
							opts.no_ignore = true
							return (use_fzf and fzf[fzf_fn] or tb_fn)(opts)
						elseif git_only and is_git then
							return (use_fzf and fzf.git_files or builtins.git_files)(opts)
						elseif not git_only then
							return (use_fzf and fzf[fzf_fn] or tb_fn)(opts)
						else
							-- fallback
							return (use_fzf and fzf.files or builtins.find_files)(opts)
						end
					end
				end

				---Creates a function that performs a live grep search using the appropriate backend
				---@param fzf_fn string @Name of the fzf-lua grep function to call (e.g. "live_grep")
				---@param tb_fn function @Telescope builtin grep function (e.g. `builtin.grep_string`)
				---@return fun():any @Function that runs the selected grep with proper options
				local function grep_searcher(fzf_fn, tb_fn)
					return function()
						local cwd = vim.uv.cwd()
						local opts = vim.deepcopy(base_opts, true)
						if cwd == vim_path then
							if use_fzf then
								opts.no_ignore = true
							else
								opts = { additional_args = { "--no-ignore" } }
							end
						end
						return (use_fzf and fzf[fzf_fn] or tb_fn)(opts)
					end
				end

				-- Tables of pickers
				local pickers = {
					file = {
						{ "Files", file_searcher("files", builtins.find_files, false) },
						{
							"Frecency",
							function()
								extensions.frecency.frecency()
							end,
						},
						{
							"Oldfiles",
							use_fzf and function()
								fzf.oldfiles(base_opts)
							end or builtins.oldfiles,
						},
						{ "Buffers", builtins.buffers },
					},
					pattern = {
						{ "Word in project", grep_searcher("live_grep", extensions.live_grep_args.live_grep_args) },
						{ "Word under cursor", grep_searcher("grep_cword", builtins.grep_string) },
					},
					git = {
						{ "Branches", builtins.git_branches },
						{ "Commits", builtins.git_commits },
						{ "Commit content", extensions.advanced_git_search.search_log_content },
						{ "Diff current file", extensions.advanced_git_search.diff_commit_file },
					},
					dossier = {
						{ "Sessions", extensions.persisted.persisted },
						{
							"Projects",
							function()
								extensions.projects.projects()
							end,
						},
						{ "Zoxide", extensions.zoxide.list },
					},
					misc = {
						{
							"Colorschemes",
							function()
								builtins.colorscheme({ enable_preview = true })
							end,
						},
						{ "Notify", extensions.notify.notify },
						{ "Undo History", extensions.undo.undo },
					},
				}

				-- Build collections
				local collections = {}
				for kind, list in pairs(pickers) do
					local init = { initial_tab = 1, tabs = {} }
					for _, entry in ipairs(list) do
						table.insert(init.tabs, { name = entry[1], tele_func = entry[2] })
					end
					collections[kind] = init
				end
				return {
					prompt_position = prompt_pos,
					collections = collections,
				}
			end,
		},
		{
			"DrKJeff16/project.nvim",
			event = { "CursorHold", "CursorHoldI" },
			main = "project",
			opts = function()
				return {
					manual_mode = false,
					lsp = {
						enabled = true,
						ignore = { "null-ls", "copilot" },
						use_pattern_matching = false,
						no_fallback = false,
					},
					patterns = {
						".bzr",
						".csproj",
						".git",
						".github",
						".hg",
						".nvim.lua",
						".pre-commit-config.yaml",
						".pre-commit-config.yml",
						".sln",
						".svn",
						"Makefile",
						"Pipfile",
						"_darcs",
						"package.json",
						"pyproject.toml",
					},
					exclude_dirs = {},
					show_hidden = false,
					silent_chdir = true,
					scope_chdir = "global",
					history = {
						save_dir = vim.fn.stdpath("data"),
					},
				}
			end,
		},
		{
			"aaronhallaert/advanced-git-search.nvim",
			cmd = { "AdvancedGitSearch" },
			dependencies = { "tpope/vim-rhubarb", "tpope/vim-fugitive", "sindrets/diffview.nvim" },
		},
	},
}
