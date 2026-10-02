return function()
	require("modules.utils").load_plugin("neotest", {
		adapters = {
			require("neotest-golang")({ runner = "go" }),
			require("neotest-vitest")({}),
			require("neotest-jest")({}),
			require("neotest-python")({}),
			require("rustaceanvim.neotest"),
		},
	})
end
