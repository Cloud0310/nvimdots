return {
	"olexsmir/gopher.nvim",
	lazy = true,
	ft = { "go", "gomod", "gosum", "gowork" },
	main = "gopher",
	-- Tool binaries come from the shared Mason manifest.
	opts = {},
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "mason-org/mason.nvim" },
}
