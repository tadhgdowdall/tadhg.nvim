local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_macos = vim.fn.has("macunix") == 1

function M.normalize_user_path(input)
	if not input or input == "" then
		return nil
	end

	local path = vim.trim(input)
	if path == "" then
		return nil
	end

	if M.is_windows then
		return path:gsub("/", "\\")
	end

	return path:gsub("\\", "/")
end

function M.ensure_directory_suffix(path)
	if not path or path == "" then
		return path
	end

	if path:match("[/\\]$") then
		return path
	end

	return path .. "/"
end

return M
