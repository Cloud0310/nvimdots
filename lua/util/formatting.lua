-- Formatting commands and policy; Conform owns formatter execution and save hooks.
local M = {}
local settings = require("config.settings")
local format_on_save = settings.format_on_save

function M.is_disabled(bufnr)
	if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
		return true
	end
	if settings.formatter_block_list[vim.bo[bufnr].filetype] then
		return true
	end
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.fs.dirname(filename) or vim.fn.getcwd()
	for _, pattern in ipairs(settings.format_disabled_dirs) do
		if vim.regex(vim.fs.normalize(pattern)):match_str(dir) ~= nil then
			return true
		end
	end
	return false
end

-- Conform's filter accepts one client, unlike the old list-based format_filter.
function M.lsp_filter(client)
	return client.name ~= "null-ls" and not settings.server_formatting_block_list[client.name]
end

function M.on_save(bufnr)
	if format_on_save and not M.is_disabled(bufnr) then
		-- Let Conform apply filetype policies (e.g. Go's external formatter then LSP).
		return { timeout_ms = settings.format_timeout, filter = M.lsp_filter }
	end
end

function M.format(opts)
	opts = opts or {}
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	if M.is_disabled(bufnr) then
		vim.notify("Formatting is disabled for this buffer.", vim.log.levels.INFO, { title = "Conform" })
		return
	end
	opts = vim.tbl_extend("force", {
		bufnr = bufnr,
		timeout_ms = settings.format_timeout,
		filter = M.lsp_filter,
	}, opts)
	return require("conform").format(opts, function(err, did_edit)
		if not err and did_edit and settings.format_notify then
			vim.notify("Buffer formatted.", vim.log.levels.INFO, { title = "Conform" })
		end
	end)
end

function M.toggle_format_on_save()
	format_on_save = not format_on_save
	vim.notify("Format on save " .. (format_on_save and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.setup_commands()
	vim.api.nvim_create_user_command("Format", function(args)
		local opts = {}
		if args.range > 0 then
			local last = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, false)[1] or ""
			opts.range = { start = { args.line1, 0 }, ["end"] = { args.line2, #last } }
		end
		M.format(opts)
	end, { range = true, desc = "Format buffer or selected range with Conform" })
	vim.api.nvim_create_user_command("FormatToggle", M.toggle_format_on_save, {
		desc = "Toggle format on save",
	})
	vim.api.nvim_create_user_command("FormatterToggleFt", function(args)
		settings.formatter_block_list[args.args] = not settings.formatter_block_list[args.args]
		vim.notify(
			"Formatting for " .. args.args .. (settings.formatter_block_list[args.args] and " disabled" or " enabled"),
			vim.log.levels.INFO
		)
	end, { nargs = 1, complete = "filetype", desc = "Toggle formatting for a filetype" })
end

return M
