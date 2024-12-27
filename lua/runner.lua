local M = {}
local output, job, win = 69, 420, 1337

local handle_stdout = function(_, data)
	if data then
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
	end
end

local run_file = function(command)
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { command, vim.api.nvim_buf_get_name(0) })
	job = vim.fn.jobstart({ command, vim.api.nvim_buf_get_name(0) }, {
		on_stdout = handle_stdout,
		on_stderr = handle_stdout,
	})
	vim.api.nvim_set_current_win(win)
end

local create_window = function()
	local width, height = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
	local buf = vim.api.nvim_create_buf(false, true)
	local opts = {
		relative = "editor",
		width = math.floor(width / 2),
		height = height,
		col = math.floor(width / 4),
		row = 1,
		anchor = "NW",
		style = "minimal",
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
