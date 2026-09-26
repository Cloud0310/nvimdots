local function load_rust_analyzer_toml(root, defaults)
	local path = root and vim.fs.joinpath(root, "rust-analyzer.toml")
	if not path or vim.fn.filereadable(path) == 0 then
		return defaults
	end

	local result = vim.system({
		"python",
		"-c",
		'import json, sys, tomllib; json.dump(tomllib.load(open(sys.argv[1], "rb")), sys.stdout)',
		path,
	}, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify("Failed to read " .. path .. ":\n" .. result.stderr, vim.log.levels.ERROR)
		return defaults
	end

	return vim.tbl_deep_extend("force", {}, defaults, {
		["rust-analyzer"] = vim.json.decode(result.stdout),
	})
end

-- rust-analyzer.toml support is still incomplete, so pass it through the LSP client.

return function()
	vim.g.rustaceanvim = {
		-- Disable automatic DAP configuration to avoid conflicts with previous user configs
		dap = {
			adapter = false,
			configuration = false,
			autoload_configurations = false,
		},
		tools = {
			executor = require("rustaceanvim.executors").toggleterm,
			reload_workspace_from_cargo_toml = true,
		},
		server = {
			standalone = true,
			settings = load_rust_analyzer_toml,
		},
	}

	require("modules.utils").load_plugin("rustaceanvim", nil, true)
end
