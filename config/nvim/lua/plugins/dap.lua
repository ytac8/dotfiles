return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-telescope/telescope-dap.nvim",
			-- デバッグ用UI
			{
				"rcarriga/nvim-dap-ui",
				config = function()
					local dapui = require("dapui")
					dapui.setup({
						-- ここからがUIのレイアウト設定
						layouts = {
							{
								-- この elements テーブルに "controls" が必要
								elements = {
									{ id = "scopes", size = 0.35 },
									{ id = "breakpoints", size = 0.15 },
									{ id = "stacks", size = 0.15 },
									{ id = "watches", size = 0.35 },
								},
								size = 40,
								position = "left",
							},
							{
								elements = {
									"repl",
								},
								size = 10,
								position = "bottom",
							},
							{
								-- ★★★ エラーの原因はここの "controls" がないこと ★★★
								elements = {
									"console",
									{ id = "controls", size = 1.0 }, -- コントロールパネルを追加
								},
								size = 10,
								position = "top",
							},
						},
						-- その他、お好みの設定
						controls = {
							enabled = true, -- コントロールを有効化
							element = "controls",
							icons = {
								pause = "⏸",
								play = "▶",
								step_into = "⏎",
								step_over = "⏭",
								step_out = "⏮",
								step_back = "b",
								run_last = "▶▶",
								terminate = "⏹",
							},
						},
						floating = {
							max_height = nil,
							max_width = nil,
							border = "single",
						},
						render = {
							max_value_lines = 100,
						},
					})

					local dap = require("dap")
					-- UIの表示/非表示を切り替えるキーマッピング
					-- vim.keymap.set("n", "<Leader>du", function()
					-- 	dapui.toggle()
					-- end, { desc = "DAP UI Toggle" })
				end,
			},
			"nvim-neotest/nvim-nio",
			{ "theHamsta/nvim-dap-virtual-text", opts = {} },
		},
		config = function()
			local dap = require("dap")
			dap.configurations.python = {
				{
					-- The first three options are required by nvim-dap
					type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
					request = "launch",
					name = "Launch file",

					-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
					program = "${file}", -- This configuration will launch the current file if used.
					pythonPath = function()
						-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
						-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
						-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
						local cwd = vim.fn.getcwd()
						if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
							return cwd .. "/venv/bin/python"
						elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
							return cwd .. "/.venv/bin/python"
						else
							return "/usr/bin/python"
						end
					end,
				},
			}
		end,
		keys = {
			{
				"<space>du",
				function()
					require("dapui").toggle()
				end,
				desc = "toggle dap-ui",
			},
			{
				"<space>dd",
				function()
					require("dap").continue()
				end,
				desc = "Debug: start/continue",
			},
			{
				"<space>dm",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Debug: toggle break(mark)",
			},
			{
				"<space>dM",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Debug: set break(mark) with message",
			},
			{
				"<space>de",
				function()
					require("dapui").eval()
				end,
				desc = "Debug: eval at cursor",
			},
			{
				"<space>dE",
				function()
					require("dapui").eval(vim.fn.input("[Expression] > "))
				end,
				desc = "Debug: eval expression",
			},
			{
				"<space>d[[",
				function()
					require("dap").step_back()
				end,
				desc = "Debug: step back (1ステップ戻る)",
			},
			{
				"<space>d]]",
				function()
					require("dap").step_over()
				end,
				desc = "Debug: step over (次のステップまで進める)",
			},
			{
				"<space>d}}",
				function()
					require("dap").step_into()
				end,
				desc = "Debug: step into (関数の中へ)",
			},
			{
				"<space>d{{",
				function()
					require("dap").step_out()
				end,
				desc = "Debug: step out (関数から外へ)",
			},
			{
				"<space>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Debug: hover",
			},
			{
				"<space>dq",
				function()
					require("dap").terminate()
				end,
				desc = "Debug: terminate (デバッグの停止)",
			},
		},
	},
}
