local M = {}
local settings = require("core.settings")
local virtual_enabled = settings.diagnostics_virtual_lines

local function apply_virtual_display()
	local severity = { min = vim.diagnostic.severity[settings.diagnostics_level] }
	vim.diagnostic.config({
		virtual_text = virtual_enabled and { current_line = false, severity = severity, source = "if_many" } or false,
		virtual_lines = virtual_enabled and { current_line = true, severity = severity } or false,
	})
end

function M.setup()
	vim.diagnostic.config({
		signs = true,
		underline = true,
		severity_sort = true,
		update_in_insert = false,
		float = { border = "rounded", source = "if_many" },
	})
	apply_virtual_display()
end

function M.toggle_virtual_lines()
	virtual_enabled = not virtual_enabled
	apply_virtual_display()
	vim.notify("Virtual diagnostics " .. (virtual_enabled and "displayed" or "hidden"), vim.log.levels.INFO)
end

return M
