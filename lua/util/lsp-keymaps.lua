local M = {}

function M.setup(buf)
	vim.keymap.set("n", "<leader>li", ":LspInfo<CR>", { remap = true, silent = true, buffer = buf, desc = "lsp: Info" })

	vim.keymap.set(
		"n",
		"<leader>lr",
		":LspRestart<CR>",
		{ remap = true, silent = true, nowait = true, buffer = buf, desc = "lsp: Restart" }
	)

	vim.keymap.set(
		"n",
		"go",
		":Trouble symbols toggle win.position=right<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Toggle outline" }
	)

	vim.keymap.set("n", "gto", function()
		require("util.search").picker("lsp_document_symbols")
	end, { remap = true, silent = true, buffer = buf, desc = "lsp: Toggle outline in Telescope" })

	vim.keymap.set("n", "g[", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { remap = true, silent = true, buffer = buf, desc = "lsp: Prev diagnostic" })

	vim.keymap.set("n", "g]", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { remap = true, silent = true, buffer = buf, desc = "lsp: Next diagnostic" })

	vim.keymap.set("n", "<leader>lx", function()
		vim.diagnostic.open_float({ scope = "line", focus = false })
	end, { remap = true, silent = true, buffer = buf, desc = "lsp: Line diagnostic" })

	vim.keymap.set("n", "gs", function()
		vim.lsp.buf.signature_help()
	end, { remap = true, desc = "lsp: Signature help" })

	vim.keymap.set(
		"n",
		"gr",
		":Lspsaga rename<CR>",
		{ remap = true, silent = true, nowait = true, buffer = buf, desc = "lsp: Rename in file range" }
	)

	vim.keymap.set(
		"n",
		"gR",
		":Lspsaga rename ++project<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Rename in project range" }
	)

	vim.keymap.set("n", "K", ":Lspsaga hover_doc<CR>", { remap = true, buffer = buf, desc = "lsp: Show doc" })

	vim.keymap.set(
		{ "n", "v" },
		"ga",
		":Lspsaga code_action<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Code action for cursor" }
	)

	vim.keymap.set(
		"n",
		"gd",
		":Lspsaga peek_definition<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Preview definition" }
	)

	vim.keymap.set(
		"n",
		"gD",
		":Lspsaga goto_definition<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Goto definition" }
	)

	vim.keymap.set("n", "gh", function()
		require("util.search").picker("lsp_references")
	end, { silent = true, nowait = true, desc = "lsp: show finder" })

	vim.keymap.set("n", "gm", function()
		require("util.search").picker("lsp_implementations")
	end, { silent = true, nowait = true, desc = "lsp: show implementations" })

	vim.keymap.set(
		"n",
		"gci",
		":Lspsaga incoming_calls<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Show incoming calls" }
	)

	vim.keymap.set(
		"n",
		"gco",
		":Lspsaga outgoing_calls<CR>",
		{ remap = true, silent = true, buffer = buf, desc = "lsp: Show outgoing calls" }
	)

	vim.keymap.set("n", "<leader>lv", function()
		require("config.diagnostics").toggle_virtual_lines()
	end, { silent = true, desc = "lsp: Toggle virtual lines" })

	vim.keymap.set("n", "<leader>lh", function()
		local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
		vim.lsp.inlay_hint.enable(not is_enabled)
		vim.notify(
			(is_enabled and "Inlay hint disabled successfully" or "Inlay hint enabled successfully"),
			vim.log.levels.INFO,
			{ title = "LSP Inlay Hint" }
		)
	end, { silent = true, desc = "lsp: Toggle inlay hints" })
end

return M
