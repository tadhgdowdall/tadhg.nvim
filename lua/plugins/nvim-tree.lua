return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			local nvimtree = require("nvim-tree")
			local api = require("nvim-tree.api")

			local function on_attach(bufnr)
				api.config.mappings.default_on_attach(bufnr)

				local function normalize_and_create()
					local orig_input = vim.ui.input
					vim.ui.input = function(opts, on_confirm)
						return orig_input(opts, function(input)
							if input and vim.fn.has("win32") == 1 then
								input = input:gsub("/", "\\")
							end
							vim.ui.input = orig_input
							on_confirm(input)
						end)
					end
					api.fs.create()
				end

				vim.keymap.set("n", "a", normalize_and_create, {
					buffer = bufnr,
					noremap = true,
					silent = true,
					desc = "Create file or directory",
				})
			end

			nvimtree.setup({
				view = {
					width = 35,
					relativenumber = true,
				},
				renderer = {
					indent_markers = {
						enable = true,
					},
					icons = {
						glyphs = {
							folder = {
								arrow_closed = "",
								arrow_open = "",
							},
						},
					},
				},
				actions = {
					open_file = {
						window_picker = {
							enable = false,
						},
					},
				},
				filters = {
					custom = { ".DS_Store" },
				},
				git = {
					ignore = false,
				},
				on_attach = on_attach,
			})

			vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		end,
	},
}
