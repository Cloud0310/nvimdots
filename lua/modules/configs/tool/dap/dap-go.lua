return function()
	require("modules.utils").load_plugin("dap-go", { delve = { path = "dlv" } })
end
