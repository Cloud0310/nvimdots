return {
	"mfussenegger/nvim-dap",
	keys = {
		{
			"<F6>",
			function()
				require("dap").continue()
			end,
			silent = true,
			desc = "debug: Run/Continue",
		},
		{
			"<F7>",
			function()
				require("dap").terminate()
			end,
			silent = true,
			desc = "debug: Stop",
		},
		{
			"<F8>",
			function()
				require("dap").toggle_breakpoint()
			end,
			silent = true,
			desc = "debug: Toggle breakpoint",
		},
		{
			"<F9>",
			function()
				require("dap").step_into()
			end,
			silent = true,
			desc = "debug: Step into",
		},
		{
			"<F10>",
			function()
				require("dap").step_out()
			end,
			silent = true,
			desc = "debug: Step out",
		},
		{
			"<F11>",
			function()
				require("dap").step_over()
			end,
			silent = true,
			desc = "debug: Step over",
		},
		{
			"<leader>db",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			silent = true,
			desc = "debug: Set breakpoint with condition",
		},
		{
			"<leader>dc",
			function()
				require("dap").run_to_cursor()
			end,
			silent = true,
			desc = "debug: Run to cursor",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			silent = true,
			desc = "debug: Run last",
		},
		{
			"<leader>do",
			function()
				require("dap").repl.open()
			end,
			silent = true,
			desc = "debug: Open REPL",
		},
		{
			"<leader>dC",
			function()
				require("dapui").close()
			end,
			silent = true,
			desc = "debug: close debug UI",
		},
	},
	lazy = true,
	cmd = {
		"DapSetLogLevel",
		"DapShowLog",
		"DapContinue",
		"DapToggleBreakpoint",
		"DapToggleRepl",
		"DapStepOver",
		"DapStepInto",
		"DapStepOut",
		"DapTerminate",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local mason_dap = require("mason-nvim-dap")

		local icons = { dap = require("util.icons").get("dap") }
		local colors = require("util.colors").get_palette()
		local mappings = require("util.dap-keymaps")

		-- Initialize debug hooks
		_G._debugging = false
		local function debug_init_cb()
			_G._debugging = true
			mappings.load_extras()
			dapui.open({ reset = true })
		end
		local function debug_terminate_cb()
			if _debugging then
				_G._debugging = false
				mappings.unload_extras()
			end
		end
		local function debug_disconnect_cb()
			if _debugging then
				_G._debugging = false
				mappings.unload_extras()
				dapui.close()
			end
		end
		dap.listeners.after.event_initialized["dapui_config"] = debug_init_cb
		dap.listeners.before.event_terminated["dapui_config"] = debug_terminate_cb
		dap.listeners.before.event_exited["dapui_config"] = debug_terminate_cb
		dap.listeners.before.disconnect["dapui_config"] = debug_disconnect_cb

		-- We need to override nvim-dap's default highlight groups, AFTER requiring nvim-dap for catppuccin.
		vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green })

		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = icons.dap.Breakpoint, texthl = "DapBreakpoint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = icons.dap.BreakpointCondition, texthl = "DapBreakpoint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapStopped", { text = icons.dap.Stopped, texthl = "DapStopped", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = icons.dap.BreakpointRejected, texthl = "DapBreakpoint", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapLogPoint",
			{ text = icons.dap.LogPoint, texthl = "DapLogPoint", linehl = "", numhl = "" }
		)

		local adapters = {
			codelldb = function()
				local dap = require("dap")
				local utils = require("util.dap")
				local is_windows = require("config.paths").is_windows

				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = vim.fn.exepath("codelldb"), -- Find codelldb on $PATH
						args = { "--port", "${port}" },
						detached = is_windows and false or true,
					},
				}
				dap.configurations.c = {
					{
						name = "Debug",
						type = "codelldb",
						request = "launch",
						program = utils.input_exec_path,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						terminal = "integrated",
					},
					{
						name = "Debug (with args)",
						type = "codelldb",
						request = "launch",
						program = utils.input_exec_path,
						args = utils.input_args,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						terminal = "integrated",
					},
					{
						name = "Attach to a running process",
						type = "codelldb",
						request = "attach",
						program = utils.input_exec_path,
						stopOnEntry = false,
						waitFor = true,
					},
				}
				dap.configurations.cpp = dap.configurations.c
				-- rustaceanvim owns Cargo-aware Rust configurations.
			end,
			js = function()
				local dap = require("dap")
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "127.0.0.1",
					port = "${port}",
					executable = { command = "js-debug-adapter", args = { "${port}" } },
				}
			end,
			lldb = function()
				local dap = require("dap")
				local utils = require("util.dap")

				dap.adapters.lldb = {
					type = "executable",
					command = vim.fn.exepath("lldb-vscode"), -- Find lldb-vscode on $PATH
				}
				dap.configurations.c = {
					{
						name = "Launch",
						type = "lldb",
						request = "launch",
						program = utils.input_exec_path,
						cwd = "${workspaceFolder}",
						args = utils.input_args,
						env = utils.get_env,

						-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
						--
						--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
						--
						-- Otherwise you might get the following error:
						--
						--    Error on launch: Failed to attach to the target process
						--
						-- But you should be aware of the implications:
						-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
						runInTerminal = false,
					},
				}

				dap.configurations.cpp = dap.configurations.c
				-- rustaceanvim owns Cargo-aware Rust configurations.
			end,
			python = function()
				local dap = require("dap")
				local utils = require("util.dap")
				local is_windows = require("config.paths").is_windows
				local debugpy_root = vim.fn.expand("$MASON/packages/debugpy")

				dap.adapters.python = function(callback, config)
					if config.request == "attach" then
						local port = (config.connect or config).port
						local host = (config.connect or config).host or "127.0.0.1"
						callback({
							type = "server",
							port = assert(port, "`connect.port` is required for a python `attach` configuration"),
							host = host,
							options = { source_filetype = "python" },
						})
					else
						callback({
							type = "executable",
							command = is_windows and debugpy_root .. "/venv/Scripts/pythonw.exe"
								or debugpy_root .. "/venv/bin/python",
							args = { "-m", "debugpy.adapter" },
							options = { source_filetype = "python" },
						})
					end
				end
				dap.configurations.python = {
					{
						-- The first three options are required by nvim-dap
						type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
						request = "launch",
						name = "Debug",
						-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
						console = "integratedTerminal",
						program = utils.input_file_path,
						pythonPath = function()
							local venv = vim.env.CONDA_PREFIX
							if venv then
								return is_windows and venv .. "/Scripts/pythonw.exe" or venv .. "/bin/python"
							else
								return is_windows and "pythonw.exe" or "python3"
							end
						end,
					},
					{
						-- NOTE: This setting is for people using venv
						type = "python",
						request = "launch",
						name = "Debug (using venv)",
						-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
						console = "integratedTerminal",
						program = utils.input_file_path,
						pythonPath = function()
							-- Prefer the venv that is defined by the designated environment variable.
							local cwd, venv = vim.uv.cwd(), vim.env.VIRTUAL_ENV
							local python = venv
									and (is_windows and venv .. "/Scripts/pythonw.exe" or venv .. "/bin/python")
								or ""
							if vim.fn.executable(python) == 1 then
								return python
							end

							-- Otherwise, fall back to check if there are any local venvs available.
							venv = vim.fn.isdirectory(cwd .. "/venv") == 1 and cwd .. "/venv" or cwd .. "/.venv"
							python = is_windows and venv .. "/Scripts/pythonw.exe" or venv .. "/bin/python"
							if vim.fn.executable(python) == 1 then
								return python
							else
								return is_windows and "pythonw.exe" or "python3"
							end
						end,
					},
				}
			end,
		}

		local function mason_dap_handler(config)
			-- nvim-dap-go owns Delve configuration; don't create a second Go adapter.
			if config.name == "delve" then
				return
			end
			local setup = adapters[config.name] or mason_dap.default_setup
			setup(config)
		end

		require("mason-nvim-dap").setup({
			-- mason-tool-installer owns installation; keep this bridge for adapter setup only.
			ensure_installed = {},
			automatic_installation = false,
			handlers = { mason_dap_handler },
		})
	end,
	dependencies = {
		{ "jay-babu/mason-nvim-dap.nvim" },
		{
			"rcarriga/nvim-dap-ui",
			dependencies = "nvim-neotest/nvim-nio",
			main = "dapui",
			opts = function()
				local icons = {
					ui = require("util.icons").get("ui"),
					dap = require("util.icons").get("dap"),
				}
				return {
					force_buffers = true,
					icons = {
						expanded = icons.ui.ArrowOpen,
						collapsed = icons.ui.ArrowClosed,
						current_frame = icons.ui.Indicator,
					},
					mappings = {
						-- Use a table to apply multiple mappings
						edit = "e",
						expand = { "<CR>", "<2-LeftMouse>" },
						open = "o",
						remove = "d",
						repl = "r",
						toggle = "t",
					},
					layouts = {
						{
							elements = {
								-- Provide as ID strings or tables with "id" and "size" keys
								{
									id = "scopes",
									size = 0.3,
								},
								{ id = "watches", size = 0.3 },
								{ id = "stacks", size = 0.3 },
								{ id = "breakpoints", size = 0.1 },
							},
							size = 0.3,
							position = "right",
						},
						{
							elements = {
								{ id = "console", size = 0.55 },
								{ id = "repl", size = 0.45 },
							},
							position = "bottom",
							size = 0.25,
						},
					},
					controls = {
						enabled = true,
						-- Display controls in this session
						element = "repl",
						icons = {
							pause = icons.dap.Pause,
							play = icons.dap.Play,
							step_into = icons.dap.StepInto,
							step_over = icons.dap.StepOver,
							step_out = icons.dap.StepOut,
							step_back = icons.dap.StepBack,
							run_last = icons.dap.RunLast,
							terminate = icons.dap.Terminate,
						},
					},
					floating = {
						border = "single",
						mappings = {
							close = { "q", "<Esc>" },
						},
					},
					render = { indent = 1, max_value_lines = 85 },
				}
			end,
		},
	},
}
