return function()
	require("modules.utils").load_plugin("mason-tool-installer", {
		ensure_installed = require("core.settings").mason_tools,
		auto_update = false,
		run_on_start = true,
		start_delay = 3000,
		-- Use Mason package names and avoid pulling LSP/DAP plugins into startup.
		integrations = {
			["mason-lspconfig"] = false,
			["mason-null-ls"] = false,
			["mason-nvim-dap"] = false,
		},
	})
end
