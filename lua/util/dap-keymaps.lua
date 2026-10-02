local M = {}
local saved = {}
local group

function M.load_extras()
	if group then
		return
	end

	local function attach(buf)
		if saved[buf] then
			return
		end
		saved[buf] = {}
		vim.api.nvim_buf_call(buf, function()
			for _, mode in ipairs({ "n", "v" }) do
				local mapping = vim.fn.maparg("K", mode, false, true)
				if mapping.buffer == 1 then
					saved[buf][mode] = mapping
				end
				vim.keymap.set(mode, "K", function()
					require("dapui").eval()
				end, { buffer = buf, nowait = true, desc = "debug: Evaluate expression under cursor" })
			end
		end)
	end

	group = vim.api.nvim_create_augroup("DapKeymaps", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function(event)
			attach(event.buf)
		end,
	})
	attach(vim.api.nvim_get_current_buf())
end

function M.unload_extras()
	if not group then
		return
	end
	vim.api.nvim_del_augroup_by_id(group)
	group = nil
	for buf, mappings in pairs(saved) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_call(buf, function()
				for _, mode in ipairs({ "n", "v" }) do
					vim.keymap.del(mode, "K", { buffer = buf })
					if mappings[mode] then
						vim.fn.mapset(mode, false, mappings[mode])
					end
				end
			end)
		end
	end
	saved = {}
end

return M
