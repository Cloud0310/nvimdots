local global = require("core.global")
local settings = require("core.settings")
local lazy_path = global.data_dir .. "lazy/lazy.nvim"
local modules_dir = global.vim_path .. "/lua/modules"

package.path = package.path .. ";" .. modules_dir .. "/configs/?.lua;" .. modules_dir .. "/configs/?/init.lua"

if not vim.uv.fs_stat(lazy_path) then
	local repo = settings.use_ssh and "git@github.com:folke/lazy.nvim.git" or "https://github.com/folke/lazy.nvim.git"
	local result = vim.system(
		{ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazy_path },
		{ text = true }
	)
		:wait()
	assert(result.code == 0, "Failed to install lazy.nvim: " .. (result.stderr or ""))
end
vim.opt.rtp:prepend(lazy_path)

local plugins = { { import = "modules.plugins" }, { import = "user.plugins" } }
for _, name in ipairs(settings.disabled_plugins) do
	plugins[#plugins + 1] = { name, enabled = false }
end

local icons = {
	kind = require("modules.utils.icons").get("kind"),
	documents = require("modules.utils.icons").get("documents"),
	ui = require("modules.utils.icons").get("ui"),
	ui_sep = require("modules.utils.icons").get("ui", true),
	misc = require("modules.utils.icons").get("misc"),
}

require("lazy").setup(plugins, {
	root = global.data_dir .. "lazy",
	concurrency = global.is_mac and 20 or nil,
	git = {
		timeout = 300,
		url_format = settings.use_ssh and "git@github.com:%s.git" or "https://github.com/%s.git",
	},
	install = { missing = true, colorscheme = { settings.colorscheme } },
	ui = {
		size = { width = 0.88, height = 0.8 },
		wrap = true,
		border = "rounded",
		icons = {
			cmd = icons.misc.Code,
			config = icons.ui.Gear,
			event = icons.kind.Event,
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			import = icons.documents.Import,
			keys = icons.ui.Keyboard,
			loaded = icons.ui.Check,
			not_loaded = icons.misc.Ghost,
			plugin = icons.ui.Package,
			runtime = icons.ui.Vim,
			source = icons.kind.StaticMethod,
			start = icons.ui.Play,
			list = {
				icons.ui_sep.BigCircle,
				icons.ui_sep.BigUnfilledCircle,
				icons.ui_sep.Square,
				icons.ui_sep.ChevronRight,
			},
		},
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"editorconfig", -- vim-sleuth handles indentation detection.
				"spellfile",
				"matchit", -- vim-matchup owns matching.
				"matchparen",
				"tohtml",
				"gzip",
				"tarPlugin",
				"zipPlugin",
			},
		},
	},
})
