-- Both neotest-vitest and neotest-jest use the pwa-node adapter name.
return function()
	local dap = require("dap")
	dap.adapters["pwa-node"] = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = { command = "js-debug-adapter", args = { "${port}" } },
	}
end
