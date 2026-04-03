return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local oil = require("oil")
			local is_windows = vim.fn.has("win32") == 1
			local actions = require("oil.actions")
			local columns = require("oil.columns")
			local parser = require("oil.mutator.parser")
			local util = require("oil.util")

			local function normalize_name(input)
				if not input or input == "" then
					return nil
				end

				if vim.fn.has("win32") == 1 then
					input = input:gsub("/", "\\")
				end

				return vim.trim(input)
			end

			local function get_name_range(bufnr, lnum)
				local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1]
				if not line then
					return nil
				end

				local adapter = util.get_adapter(bufnr)
				if not adapter then
					return nil
				end

				local result = parser.parse_line(adapter, line, columns.get_supported_columns(adapter))
				if not result or not result.ranges or not result.ranges.name then
					return nil
				end

				local start_col = result.ranges.name[1]
				local end_col = result.ranges.name[2]
				return line:sub(1, start_col - 1), line:sub(end_col + 1)
			end

			local function replace_name_under_cursor(new_name)
				local bufnr = vim.api.nvim_get_current_buf()
				local lnum = vim.api.nvim_win_get_cursor(0)[1]
				local prefix, suffix = get_name_range(bufnr, lnum)
				if not prefix then
					return false
				end

				vim.api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, true, { prefix .. new_name .. suffix })
				return true
			end

			local function delete_entry()
				local entry = oil.get_cursor_entry()
				if not entry then
					return
				end

				local prompt = ("Delete '%s'? [y/N] "):format(entry.name)
				vim.api.nvim_echo({ { prompt, "WarningMsg" } }, false, {})
				local choice = vim.fn.nr2char(vim.fn.getchar())
				choice = choice:lower()
				vim.api.nvim_echo({ { "" } }, false, {})
				if choice ~= "y" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local lnum = vim.api.nvim_win_get_cursor(0)[1]
				vim.api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, true, {})
			end

			local function rename_entry()
				local entry = oil.get_cursor_entry()
				if not entry then
					return
				end

				vim.ui.input({ prompt = "Rename to: ", default = entry.name }, function(input)
					local new_name = normalize_name(input)
					if not new_name or new_name == entry.name then
						return
					end

					if entry.type == "directory" and not new_name:match("[/\\]$") then
						new_name = new_name .. "/"
					end

					if not replace_name_under_cursor(new_name) then
						vim.notify("Failed to stage rename", vim.log.levels.ERROR)
						return
					end
				end)
			end

			local function create_entry()
				vim.ui.input({ prompt = "Create file or folder: " }, function(input)
					local name = normalize_name(input)
					if not name then
						return
					end

					local bufnr = vim.api.nvim_get_current_buf()
					local lnum = vim.api.nvim_win_get_cursor(0)[1]
					if name:match("[/\\]$") and vim.fn.has("win32") == 1 then
						name = name:gsub("\\$", "/")
					end
					vim.api.nvim_buf_set_lines(bufnr, lnum, lnum, true, { name })
					vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
				end)
			end

			local function get_sidebar_dir()
				local current = vim.api.nvim_buf_get_name(0)
				if current == "" then
					return vim.fn.getcwd()
				end

				local stat = vim.uv.fs_stat(current)
				if stat and stat.type == "directory" then
					return current
				end

				return vim.fn.fnamemodify(current, ":p:h")
			end

			local function find_oil_window()
				for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "oil" then
						return win, buf
					end
				end
			end

			local function find_main_window()
				for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype ~= "oil" then
						return win
					end
				end
			end

			local function select_in_sidebar()
				if not vim.w.is_oil_sidebar then
					actions.select.callback()
					return
				end

				local entry = oil.get_cursor_entry()
				if not entry then
					return
				end

				if entry.type == "directory" then
					actions.select.callback()
					return
				end

				local target_win = find_main_window()
				if not target_win then
					vim.cmd("wincmd l")
					if vim.api.nvim_get_current_win() == find_oil_window() then
						vim.cmd("rightbelow vsplit")
					end
					target_win = vim.api.nvim_get_current_win()
				end

				oil.select({
					close = false,
					handle_buffer_callback = function(bufnr)
						if vim.api.nvim_win_is_valid(target_win) then
							vim.api.nvim_win_set_buf(target_win, bufnr)
							vim.api.nvim_set_current_win(target_win)
						end
					end,
				})
			end

			local function toggle_oil_sidebar()
				local oil_win = find_oil_window()
				if oil_win then
					if oil_win == vim.api.nvim_get_current_win() then
						vim.api.nvim_win_close(oil_win, true)
					else
						vim.api.nvim_set_current_win(oil_win)
					end
					return
				end

				vim.cmd("topleft vsplit")
				vim.cmd("vertical resize 32")
				oil.open(get_sidebar_dir())
				local win = vim.api.nvim_get_current_win()
				vim.wo[win].winfixwidth = true
				vim.w.is_oil_sidebar = true
			end

			local function open_oil_fullscreen()
				oil.open(get_sidebar_dir())
				vim.w.is_oil_sidebar = false
			end

			require("oil").setup({
				default_file_explorer = true,
				delete_to_trash = is_windows,
				view_options = {
					show_hidden = true,
				},
				keymaps = {
					["g?"] = { "actions.show_help", mode = "n" },
					["<CR>"] = { select_in_sidebar, mode = "n", desc = "Open entry in main pane" },
					["<C-p>"] = "actions.preview",
					["<C-l>"] = "actions.refresh",
					["-"] = { "actions.parent", mode = "n" },
					["g\\"] = { "actions.toggle_trash", mode = "n" },
					["a"] = { create_entry, mode = "n", desc = "Create file or folder" },
					["d"] = { delete_entry, mode = "n", desc = "Delete entry to trash" },
					["r"] = { rename_entry, mode = "n", desc = "Rename entry" },
				},
				use_default_keymaps = false,
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set("n", "<leader>ee", toggle_oil_sidebar, { desc = "Toggle file explorer sidebar" })
			vim.keymap.set("n", "<leader>ef", open_oil_fullscreen, { desc = "Open full file explorer" })
		end,
	},
}
