local M = {}
local default_target = function()
	return vim.fn.expand("%")
end

local output, job, win = -1, -1, -1

local handle_stdout = function(_, data)
	if data then
		vim.api.nvim_set_option_value("readonly", false, { buf = output })
		vim.api.nvim_buf_set_lines(output, -1, -1, false, data)
		vim.api.nvim_set_option_value("readonly", true, { buf = output })
	end
end

local run = function(runner)
	vim.api.nvim_set_option_value("readonly", false, { buf = output })
	vim.api.nvim_buf_set_lines(output, 0, -1, false, { "OUTPUT: " })
	vim.api.nvim_set_option_value("readonly", true, { buf = output })

	job = vim.fn.jobstart({ runner.command, runner.target() }, {
		on_stdout = handle_stdout,
		on_stderr = handle_stdout,
	})
end

local create_window = function()
	local buf = vim.api.nvim_create_buf(false, true)
	local width, height = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
	local opts = {
		relative = "editor",
		width = math.floor(width / 2),
		height = height,
		col = math.floor(width / 2),
		row = 1,
		anchor = "NW",
		style = "minimal",
	}
	win = vim.api.nvim_open_win(buf, false, opts)
	output = buf
	vim.api.nvim_set_option_value("readonly", true, { buf = output })
end

local runners = {
	["lua"] = { target = default_target, command = "lua" },
	["javascript"] = { target = default_target, command = "node" },
	["python"] = { target = default_target, command = "python3" },
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
		if not v.target then
			v.target = default_target
		end
		runners[k] = v
	end
end

return M
