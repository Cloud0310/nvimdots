return function()
	require("completion.neoconf").setup()

	local settings = require("core.settings")
	local registry = require("mason-registry")
	local mason_lspconfig = require("mason-lspconfig")
	mason_lspconfig.setup({
		ensure_installed = {}, -- mason-tool-installer owns installation.
		automatic_enable = false, -- Apply the disabled-server list and Rust ownership below.
	})
	vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities({}, true) })

	-- Merge our settings directly into nvim-lspconfig's server defaults.
	local servers = {
		bashls = {
			cmd = { "bash-language-server", "start" },
			filetypes = { "bash", "sh" },
		},
		-- A compile_commands.json in the project/build directory is recommended.
		clice = {
			cmd = { "clice", "serve" },
			filetypes = { "c", "cpp" },
			root_markers = {
				"clice.toml",
				"compile_commands.json",
				"compile_flags.txt",
				".clang-tidy",
				".clang-format",
				"configure.ac",
				".git",
			},
			capabilities = {
				textDocument = { completion = { editsNearCursor = true } },
				offsetEncoding = { "utf-8" },
			},
		},
		dartls = {
			cmd = { "dart", "language-server", "--protocol=lsp" },
			filetypes = { "dart" },
			init_options = {
				closingLabels = true,
				flutterOutline = true,
				onlyAnalyzeProjectsWithOpenFiles = true,
				outline = true,
				suggestFromUnimportedLibraries = true,
			},
		},
		-- Based on rami3l's Go configuration, including shadow=false.
		gopls = {
			cmd = { "gopls" },
			settings = {
				gopls = {
					analyses = {
						ST1003 = true,
						fieldalignment = false,
						fillreturns = true,
						nilness = true,
						nonewvars = true,
						shadow = false,
						undeclaredname = true,
						unreachable = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					codelenses = {
						generate = true,
						regenerate_cgo = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					buildFlags = { "-tags", "integration" },
					completeUnimported = true,
					diagnosticsDelay = "500ms",
					gofumpt = true,
					matcher = "Fuzzy",
					semanticTokens = true,
					staticcheck = true,
					symbolMatcher = "fuzzy",
					usePlaceholders = true,
				},
			},
		},
		html = {
			cmd = { "html-languageserver", "--stdio" },
			filetypes = { "html" },
			init_options = {
				configurationSection = { "html", "css", "javascript" },
				embeddedLanguages = { css = true, javascript = true },
			},
			flags = { debounce_text_changes = 500 },
			single_file_support = true,
			settings = {},
		},
		jsonls = {
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		},
		lua_ls = {
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = {
						globals = { "vim" },
						disable = { "different-requires", "undefined-field" },
					},
					workspace = {
						library = {
							vim.fn.expand("$VIMRUNTIME/lua"),
							vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
						},
						maxPreload = 100000,
						preloadFileSize = 10000,
					},
					hint = { enable = true, setType = true },
					format = { enable = false },
					telemetry = { enable = false },
					-- Keep Treesitter's Lua highlighting.
					semantic = { enable = false },
				},
			},
		},
		-- A .marksman.toml or Git root enables cross-document workspace features.
		marksman = {
			cmd = { "marksman", "server" },
			filetypes = { "markdown", "markdown.mdx" },
			root_markers = { ".marksman.toml", ".git" },
		},
		-- Keep upstream's command, project detection and fix-all handler.
		oxlint = { settings = { run = "onType" } },
		ruff = {
			cmd = { "ruff", "server" },
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
			settings = {
				init_options = {
					settings = {
						lint = {
							select = { "E", "F" }, -- pycodestyle, pyflakes
							extendSelect = { "I" }, -- isort
							lineLength = 88,
						},
						configurationPreference = "filesystemFirst",
					},
				},
			},
		},
		tombi = {
			cmd = { "tombi", "lsp" },
			filetypes = { "toml" },
			root_markers = { "tombi.toml", "pyproject.toml", "Cargo.toml", ".git" },
		},
		-- Keep upstream's native TS 7+ command and monorepo/Deno detection.
		tsc = {
			settings = {
				["js/ts"] = {
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
					},
				},
			},
		},
		yamlls = {
			settings = {
				yaml = {
					-- SchemaStore.nvim supplies the catalog; don't fetch another one.
					schemaStore = { enable = false, url = "" },
					schemas = require("schemastore").yaml.schemas(),
					validate = true,
				},
			},
		},
	}
	for server, config in pairs(servers) do
		vim.lsp.config(server, config)
	end

	local function enable_package(name)
		local server = mason_lspconfig.get_mappings().package_to_lspconfig[name]
		if server and server ~= "rust_analyzer" and not vim.tbl_contains(settings.disabled_lsp_servers, server) then
			vim.lsp.enable(server)
		end
	end

	registry:on(
		"package:install:success",
		vim.schedule_wrap(function(pkg)
			enable_package(pkg.name)
		end)
	)
	for _, name in ipairs(registry.get_installed_package_names()) do
		enable_package(name)
	end

	-- Dart ships its server with the SDK rather than through Mason.
	if vim.fn.executable("dart") == 1 then
		vim.lsp.enable("dartls")
	end
end
