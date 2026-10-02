local os_name = vim.uv.os_uname().sysname
local is_windows = os_name == "Windows_NT"

return {
	is_mac = os_name == "Darwin",
	is_linux = os_name == "Linux",
	is_windows = is_windows,
	is_wsl = vim.fn.has("wsl") == 1,
	vim_path = vim.uv.fs_realpath(vim.fn.stdpath("config")),
	cache_dir = vim.fn.stdpath("cache"),
	data_dir = vim.fn.stdpath("data") .. "/site/",
	home = is_windows and vim.env.USERPROFILE or vim.env.HOME,
}
