return function()
	-- Tool binaries come from the shared Mason manifest, not a plugin build/install hook.
	require("modules.utils").load_plugin("gopher", {})
end
