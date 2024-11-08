local M = {}

local data_path = vim.fn.stdpath("data") .. "/marker-cache/marker-cache.json"
local augroup = vim.api.nvim_create_augroup("marker", { clear = true })

local function ensure_directory_exists()
	local dir_path = vim.fn.fnamemodify(data_path, ":h")
	if vim.fn.isdirectory(dir_path) == 0 then
		vim.fn.mkdir(dir_path, "p")
	end
end

local load_table_from_data = function()
	if vim.fn.filereadable(data_path) == 1 then
		local json = vim.fn.json_decode(vim.fn.readfile(data_path))
		return json
	else
		return {}
	end
end

local function save_table_to_data(table)
	local json = vim.fn.json_encode(table)
	vim.fn.writefile({ json }, data_path)
end

local function load_marks()
	local cur_buf_path = vim.api.nvim_buf_get_name(0)
	local marks_data = load_table_from_data()
	local cur_buf_marks = marks_data[cur_buf_path] or {}
	for key, value in pairs(cur_buf_marks) do
		vim.api.nvim_buf_set_mark(0, key, value[1], value[2], {})
	end
end

local function add_mark()
	local key = vim.fn.nr2char(vim.fn.getchar())
	vim.api.nvim_command("normal! m" .. key)
	local cur_buf_path = vim.api.nvim_buf_get_name(0)
	local marks_data = load_table_from_data()
	marks_data[cur_buf_path] = marks_data[cur_buf_path] or {}
	marks_data[cur_buf_path][key] = vim.api.nvim_win_get_cursor(0)
	save_table_to_data(marks_data)
end
M.add_mark = add_mark

local setup = function()
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = augroup,
		callback = load_marks,
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		callback = ensure_directory_exists,
	})
end
M.setup = setup

return M
