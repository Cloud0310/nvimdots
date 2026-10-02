-- Autoclose NvimTree
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeAutoClose", { clear = true }),
	pattern = "NvimTree_*",
	callback = function()
		local layout = vim.api.nvim_call_function("winlayout", {})
		if
			layout[1] == "leaf"
			and vim.bo[vim.api.nvim_win_get_buf(layout[2])].filetype == "NvimTree"
			and layout[3] == nil
		then
			vim.api.nvim_command([[confirm quit]])
		end
	end,
})

-- Autoclose some filetype with <q>
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"nofile",
		"terminal",
		"prompt",
		"toggleterm",
		"copilot",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true, remap = true })
	end,
})

-- Hold off on configuring anything related to the LSP until LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspKeymapLoader", { clear = true }),
	callback = function(event)
		if not _G._debugging then
			-- LSP Keymaps
			require("util.lsp-keymaps").setup(event.buf)

			-- LSP Inlay Hints
			local inlayhints_enabled = require("config.settings").lsp_inlayhints
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.inlayHintProvider ~= nil then
				vim.lsp.inlay_hint.enable(inlayhints_enabled == true, { bufnr = event.buf })
			end
		end
	end,
})

-- Start treesitter for installed parsers
vim.api.nvim_create_autocmd("FileType", {
	pattern = require("config.settings").treesitter_deps,
	callback = function(args)
		vim.treesitter.start(args.buf)
	end,
})

-- Autojump to last edit
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

local buffers = vim.api.nvim_create_augroup("_bufs", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
	group = buffers,
	pattern = "*.vim",
	nested = true,
	command = "if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif",
})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = buffers,
	pattern = { "*~", "/tmp/*", "*.tmp", "*.bak", "MERGE_MSG", "description", "COMMIT_EDITMSG" },
	callback = function(event)
		vim.bo[event.buf].undofile = false
	end,
})
local windows = vim.api.nvim_create_augroup("_wins", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
	group = windows,
	command = [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
	group = windows,
	command = [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
})
vim.api.nvim_create_autocmd("VimLeave", { group = windows, command = "wshada" })
vim.api.nvim_create_autocmd("FocusGained", { group = windows, command = "checktime" })
vim.api.nvim_create_autocmd("VimResized", { group = windows, command = "tabdo wincmd =" })

local filetypes = vim.api.nvim_create_augroup("_ft", { clear = true })
vim.api.nvim_create_autocmd("FileType", { group = filetypes, command = "setlocal formatoptions-=cro" })
vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = "alpha",
	command = "setlocal showtabline=0",
})
vim.api.nvim_create_autocmd("FileType", { group = filetypes, pattern = "markdown", command = "setlocal wrap" })
vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = "dap-repl",
	callback = function()
		require("dap.ext.autocompl").attach()
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = filetypes,
	pattern = { "c", "cpp" },
	callback = function(event)
		vim.keymap.set("n", "<leader>h", "<Cmd>ClangdSwitchSourceHeader<CR>", { buffer = event.buf, silent = true })
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})
