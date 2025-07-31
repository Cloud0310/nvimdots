local M = {}

M.setup = function()
	local is_windows = require("core.global").is_windows

	local lsp_deps = require("core.settings").lsp_deps
	local use_python_experimental_lsp = require("core.settings").use_python_experimental_lsp
	local python_experimental_lsp_deps = require("core.settings").python_experimental_lsp_deps
	local mason_registry = require("mason-registry")
	local mason_lspconfig = require("mason-lspconfig")

	require("lspconfig.ui.windows").default_options.border = "rounded"
	local load_plugin = require("modules.utils").load_plugin

	local lsp_deps_with_python = lsp_deps
	local has_python_experimental_lsp_deps = python_experimental_lsp_deps and #python_experimental_lsp_deps > 0

	if use_python_experimental_lsp and has_python_experimental_lsp_deps then
		-- If using experimental Python LSP, add the experimental LSPs to the list of dependencies
		lsp_deps_with_python = vim.list_extend(lsp_deps, python_experimental_lsp_deps)
		table.insert(lsp_deps_with_python, "ruff") -- ruff is used for linting and formatting
	elseif use_python_experimental_lsp and not has_python_experimental_lsp_deps then
		-- Experimental LSP desired, but dependencies are missing/empty.
		-- Warn and fall back to pylsp.
		vim.notify(
			[[
If you want to use the experimental Python LSP,
please set `python_experimental_lsp_deps` (a table of LSP names) in your settings.
Fallback to default `pylsp` now.]],
			vim.log.levels.WARN,
			{ title = "nvim-lspconfig" }
		)
		table.insert(lsp_deps_with_python, "pylsp")
	else
		-- Experimental LSP is not desired. Use default pylsp.
		table.insert(lsp_deps_with_python, "pylsp")
	end

	load_plugin("mason-lspconfig", {
		ensure_installed = lsp_deps_with_python,
		automatic_enable = false,
	})

	vim.diagnostic.config({
		signs = true,
		underline = true,
		virtual_text = false,
		update_in_insert = false,
	})

	local opts = {
		capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		),
	}
	---A handler to setup all servers defined under `completion/servers/*.lua`
	---@param lsp_name string
	local function mason_lsp_handler(lsp_name)
		-- rust_analyzer is configured using mrcjkb/rustaceanvim
		-- warn users if they have set it up manually
		if lsp_name == "rust_analyzer" then
			local config_exist = pcall(require, "completion.servers." .. lsp_name)
			if config_exist then
				vim.notify(
					[[
`rust_analyzer` is configured independently via `mrcjkb/rustaceanvim`. To get rid of this warning,
please REMOVE your LSP configuration (rust_analyzer.lua) from the `servers` directory and configure
`rust_analyzer` using the appropriate init options provided by `rustaceanvim` instead.]],
					vim.log.levels.WARN,
					{ title = "nvim-lspconfig" }
				)
			end
			return
		end

		local ok, custom_handler = pcall(require, "user.configs.lsp-servers." .. lsp_name)
		local default_ok, default_handler = pcall(require, "completion.servers." .. lsp_name)
		-- Use preset if there is no user definition
		if not ok then
			ok, custom_handler = default_ok, default_handler
		end

		if not ok then
			-- Default to use factory config for server(s) that doesn't include a spec
			require("modules.utils").register_server(lsp_name, opts)
		elseif type(custom_handler) == "function" then
			-- Case where language server requires its own setup
			-- Be sure to call `vim.lsp.config()` within the setup function.
			-- Refer to |vim.lsp.config()| for documentation.
			-- For an example, see `clangd.lua`.
			custom_handler(opts)
			vim.lsp.enable(lsp_name)
		elseif type(custom_handler) == "table" then
			require("modules.utils").register_server(
				lsp_name,
				vim.tbl_deep_extend(
					"force",
					opts,
					type(default_handler) == "table" and default_handler or {},
					custom_handler
				)
			)
		else
			vim.notify(
				string.format(
					"Failed to setup [%s].\n\nServer definition under `completion/servers` must return\neither a fun(opts) or a table (got '%s' instead)",
					lsp_name,
					type(custom_handler)
				),
				vim.log.levels.ERROR,
				{ title = "nvim-lspconfig" }
			)
		end
	end

	--- the LSP for python should be set up differently depend on the value of `use_python_experimental_lsp`.
	--- If both `use_python_experimental_lsp` and `python_experimental_lsp_deps` are set,
	--- we'll use the experimental LSP with the specified dependencies.
	--- Otherwise, default `pylsp` will be used.
	if use_python_experimental_lsp then
		if not python_experimental_lsp_deps or #python_experimental_lsp_deps == 0 then
			vim.notify(
				[[
If you want to use the experimental Python LSP,
please set `python_experimental_lsp_deps` in your settings.
Fallback to default `pylsp` now.]],
				vim.log.levels.WARN,
				{ title = "nvim-lspconfig" }
			)
		else
			mason_lsp_handler("pylsp")
		end
	else
		for _, exp_py_lsp in ipairs(python_experimental_lsp_deps) do
			mason_lsp_handler(exp_py_lsp)
		end
		mason_lsp_handler("ruff") -- for linting and formatting as the exp LSPs do not support it
	end

	---A simplified mimic of <mason-lspconfig 1.x>'s `setup_handlers` callback.
	---Invoked for each Mason package (name or `Package` object) to configure its language server.
	---@param pkg string|{name: string} Either the package name (string) or a Package object
	local function setup_lsp_for_package(pkg)
		-- First try to grab the builtin mappings
		local mappings = mason_lspconfig.get_mappings().package_to_lspconfig
		-- If empty or nil, build it by hand
		if not mappings or vim.tbl_isempty(mappings) then
			mappings = {}
			for _, spec in ipairs(mason_registry.get_all_package_specs()) do
				local lspconfig = vim.tbl_get(spec, "neovim", "lspconfig")
				if lspconfig then
					mappings[spec.name] = lspconfig
				end
			end
		end

		-- Figure out the package name and lookup
		local name = type(pkg) == "string" and pkg or pkg.name
		local srv = mappings[name]
		if not srv then
			return
		end

		-- Invoke the handler
		mason_lsp_handler(srv)
	end

	for _, pkg in ipairs(mason_registry.get_installed_package_names()) do
		setup_lsp_for_package(pkg)
	end

	--- the LSP for python should be set up differently depend on the value of `use_python_experimental_lsp`.
	--- If both `use_python_experimental_lsp` and `python_experimental_lsp_deps` are set,
	--- we'll use the experimental LSP with the specified dependencies.
	--- Otherwise, default `pylsp` will be used.
	if use_python_experimental_lsp then
		if not python_experimental_lsp_deps or #python_experimental_lsp_deps == 0 then
			vim.notify(
				[[
If you want to use the experimental Python LSP,
please set `python_experimental_lsp_deps` in your settings.
Fallback to default `pylsp` now.]],
				vim.log.levels.WARN,
				{ title = "nvim-lspconfig" }
			)
		else
			setup_lsp_for_package("pylsp")
		end
	else
		for _, exp_py_lsp in ipairs(python_experimental_lsp_deps) do
			setup_lsp_for_package(exp_py_lsp)
		end
		mason_lsp_handler("ruff") -- for linting and formatting as the exp LSPs do not support it
	end
end

return M
