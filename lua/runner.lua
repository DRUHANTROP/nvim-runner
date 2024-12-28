local M = {}
local output, job, win = 69, 420, 1337

local handle_stdout = function(_, data)
	if data then
		print(data[1])
		if vim.trim(data[1]) == "[H[J" then
			vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })
			return
		end
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
	end
end

local run_file = function(command)
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })
	job = vim.fn.jobstart({ command, vim.api.nvim_buf_get_name(0) }, {
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
	["lua"] = { is_interpreted = true, command = "lua", run = run_file },
	["javascript"] = { is_interpreted = true, command = "node", run = run_file },
}

M.run_current_cwd = function()
	local runner = runners[vim.bo.filetype]
	if not runner then
		print("You didn't teach me how to run it")
		return
	end
	create_window()
	runner.run(runner.command)
end

M.setup = function(opts)
	print("hello !", opts)
end

M.close = function()
	vim.fn.jobstop(job)
end

print("lol")
return M
