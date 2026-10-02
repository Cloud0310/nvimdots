return function()
	local settings = require("core.settings")
	local formatting = require("completion.formatting")
	local formatters_by_ft = {
		lua = { "stylua" },
		-- Match rami3l: import organization first, then gopls with gofumpt=true.
		go = { "goimports", lsp_format = "last" },
		toml = { "tombi" },
		python = { "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	}
	for _, ft in ipairs({ "c", "cpp", "objc", "objcpp", "cs", "cuda", "proto" }) do
		formatters_by_ft[ft] = { "clang-format" }
	end
	-- Use Oxfmt's npm distribution for non-native formats. Astro is not supported.
	-- Svelte additionally needs the project's `svelte` dependency and Oxfmt `svelte: true`.
	for _, ft in ipairs({
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"vue",
		"svelte",
		"json5",
		"yaml",
		"html",
		"css",
		"scss",
		"less",
		"markdown",
		"markdown.mdx",
		"graphql",
	}) do
		formatters_by_ft[ft] = { "oxfmt" }
	end

	require("modules.utils").load_plugin("conform", {
		formatters_by_ft = formatters_by_ft,
		default_format_opts = { lsp_format = "fallback", timeout_ms = settings.format_timeout },
		format_on_save = formatting.on_save,
		notify_on_error = true,
		notify_no_formatters = true,
		formatters = {
			-- Saving must not wait for remote schema downloads; Tombi can use its local cache.
			tombi = { append_args = { "--offline" } },
			["clang-format"] = {
				prepend_args = function(_, ctx)
					local config = vim.fs.find({ ".clang-format", "_clang-format" }, {
						path = vim.fs.dirname(ctx.filename),
						upward = true,
					})[1]
					return config and { "--style=file" } or { "--style={ BasedOnStyle: LLVM, IndentWidth: 4 }" }
				end,
			},
		},
	})
	formatting.setup_commands()
end
