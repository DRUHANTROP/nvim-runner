local M = {}
local kind = { SINGLE_FILE = 1, CWD = 2, CUSTOM = 3 }
local target = { [1] = vim.fn.expand("%"), [2] = vim.fn.getcwd(), [3] = {} }
local output, job, win = 69, 420, 1337

local handle_stdout = function(_, data)
	if data then
		print(data[1])
		if vim.trim(data[1]) == "[H[2J" then
			vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })
			return
		end
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
	end
end

local run = function(runner)
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })

	job = vim.fn.jobstart({ runner.command, target[runner.kind] }, {
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

local run_current_cwd = function()
	local runner = runners[vim.bo.filetype]
	if not runner then
		print("You didn't teach me how to run it")
		return
	end
	create_window()
	run(runner)
end

local close = function()
	vim.fn.jobstop(job)
	if vim.api.nvim_buf_is_loaded(output) then
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(output, { force = true })
	end
end

M.setup = function(opts)
	vim.api.nvim_create_user_command("FreeRun", function()
		run_current_cwd()
	end, {})

	vim.api.nvim_create_user_command("FreeStop", function()
		close()
	end, {})

	if opts.runners then
		runners.insert(opts.runners)
	end
end

return M
