return function()
	vim.g.rustaceanvim = {
		tools = {
			executor = "toggleterm",
			enable_clippy = true,
			reload_workspace_from_cargo_toml = true,
		},
		server = {
			settings = function(root, defaults)
				-- Preserve upstream defaults and Clippy detection before applying project settings.
				local settings = require("rustaceanvim.config.server").load_rust_analyzer_settings(root, {
					default_settings = vim.deepcopy(defaults),
				})
				local path = root and (root .. "/rust-analyzer.toml")
				if not path or vim.fn.filereadable(path) == 0 then
					return settings
				end

				-- Python 3.11+ provides a TOML parser in the standard library.
				local result = vim.system({
					"python3",
					"-c",
					[[
import json, sys, tomllib
with open(sys.argv[1], "rb") as f:
    print(json.dumps(tomllib.load(f)))
]],
					path,
				}, { text = true }):wait()
				if result.code ~= 0 then
					error("Cannot load " .. path .. ": " .. result.stderr)
				end

				settings["rust-analyzer"] =
					vim.tbl_deep_extend("force", settings["rust-analyzer"], vim.json.decode(result.stdout))
				return settings
			end,
		},
		-- Rust debug targets come from Cargo; C/C++ adapters must not assign Rust configurations.
	}

	require("modules.utils").load_plugin("rustaceanvim", nil, true)
end
