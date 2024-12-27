local M = {}
local output = 69

local handle_stdout = function(_, data)
	if data then
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
	end
end

local run_lua = function()
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT:" })
	local job = vim.fn.jobstart({ "lua", vim.api.nvim_buf_get_name(0) }, {
		stdout_buffered = true,
		on_stdout = handle_stdout,
		on_stderr = handle_stdout,
		-- on_exit = handle_stdout(nil, { "-EXIT-" }),
	})
end

local runners = {
	["lua"] = { is_interpreted = true, runner_name = "lua", run = run_lua },
}

M.run_current_cwd = function()
	local runner = runners[vim.bo.filetype]
	if not runner then
		print("You didn't teach me how to run it")
		return
	end
	local width, height = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
	local buf = vim.api.nvim_create_buf(false, true)
	local opts = {
		relative = "editor",
		width = math.floor(width / 2),
		height = height,
		col = math.floor(width / 2),
		row = 1,
		anchor = "NW",
		style = "minimal",
	}
	vim.api.nvim_open_win(buf, false, opts)
	output = buf
	runner.run()
end

M.setup = function(opts)
	print("hello !", opts)
end
print("lol")
return M
