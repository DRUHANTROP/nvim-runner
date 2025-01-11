local M = {}
local kind = { SINGLE_FILE = 1, CWD = 2, CUSTOM = 3 }
local target = {
	[1] = function()
		return vim.fn.expand("%")
	end,
	[2] = vim.fn.getcwd,
	[3] = function() end,
}

local output, job, win = -1, -1, -1

local handle_stdout = function(_, data)
	if data then
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
	end
end

local run = function(runner)
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })

	-- local path = target[runner.kind]()
	job = vim.fn.jobstart({ runner.command, target[runner.kind]() }, {
		on_stdout = handle_stdout,
		on_stderr = handle_stdout,
	})
	vim.api.nvim_set_current_win(win)
end

local create_window = function()
	local buf = vim.api.nvim_create_buf(false, true)
	local opts = {
		split = "right",
		win = 0,
	}
	win = vim.api.nvim_open_win(buf, false, opts)
	output = buf
end

local runners = {
	["lua"] = { kind = kind.SINGLE_FILE, command = "lua" },
	["javascript"] = { kind = kind.SINGLE_FILE, command = "node" },
}

local close = function()
	vim.fn.jobstop(job)
	vim.api.nvim_win_close(win, true)
	vim.api.nvim_buf_delete(output, { force = true })
end

local run_current_cwd = function()
	if vim.api.nvim_buf_is_loaded(output) then
		close()
		return
	end

	local runner = runners[vim.bo.filetype]

	if not runner then
		print("You didn't teach me how to run it")
		return
	end
	create_window()
	run(runner)
end

M.setup = function(opts)
	vim.api.nvim_create_user_command("ToggleRun", function()
		run_current_cwd()
	end, {})

	for k, v in pairs(opts.runners) do
		runners[k] = v
	end
end

return M
