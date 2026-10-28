local OS_NAME = vim.loop.os_uname().sysname

-- ///////////////////////////////////////////////////
-- ~_ag: settings
vim.opt.clipboard = "unnamedplus" -- uses clipboard
vim.o.guifont = "0xProto Nerd Font Mono:h12"
vim.g.neovide_scroll_animation_length = 0.15

if OS_NAME == 'Darwin' then
	vim.g.neovide_input_macos_option_key_is_meta = 'only_left' -- 'only_left,' 'both', 'only_right', 'none'
end




vim.opt.tabstop = 1       -- Visual width of a tab
vim.opt.shiftwidth = 0    -- Width of an auto-indent
vim.opt.expandtab = false -- Expand tabs into spaces
vim.opt.smartindent = false
vim.opt.cindent = true
vim.opt.wrap = false

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

vim.g.have_nerd_font = true
-- ~_ag NOTE: custom highlights, reapplied after every colorscheme load
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ag-custom-highlights", { clear = true }),
	callback = function()
		local hl = vim.api.nvim_set_hl
		hl(0, "Cursor", { fg = "#000000", bg = "#00cc7f" }) -- normal
		hl(0, "iCursor", { fg = "#000000", bg = "#ff007f" }) -- insert
		hl(0, "vCursor", { fg = "#000000", bg = "#2277ff" }) -- visual
		hl(0, "rCursor", { fg = "#000000", bg = "#ff0000" }) -- replace
		hl(0, "DiagnosticVirtualTextError", { fg = "#FF0000", bold = true })
	end,
})

-- set cursor to always be a block []
-- guicursor map modes to highlight groups
vim.opt.guicursor = {
	'n-v-c:block-Cursor',
	'i-ci:block-iCursor',
	'v:block-vCursor',
	'r:block-rCursor',
}

vim.opt.nu = true --line numbers
vim.opt.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Show which line your cursor is on
vim.o.cursorline = false
vim.opt.scrolloff = 999


-- ///////////////////////////////////////////////////
-- ~_ag NOTE: command palette registry
-- 						items in this list will be appended to telescope in the <C-x> menu
-- 						this replaces decrement but it wasnt that usefull anywyas
_G.cmd_palette = { items = {} }
function cmd_palette.add(name, fn)
	table.insert(cmd_palette.items, { name = name, fn = fn })
end

cmd_palette.add("marks: delete all", function() vim.cmd("delmarks!") end)
cmd_palette.add("open neovim config", function() vim.cmd('exe "edit" stdpath("config") . "/init.lua"') end)
cmd_palette.add('Scracth buffer', function()
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
end)




-- ~_ag NOTE:  Select C compiler per os
-- 												sure do love having multiple C compilers :)
if     OS_NAME == 'Windows_NT' then

	vim.cmd.compiler("msvc")
	vim.opt.makeprg = "call build"

elseif OS_NAME == 'Darwin' then

	vim.cmd.compiler("gcc")
	vim.opt.makeprg = "sh build.sh"

end

-- ~_ag NOTE: set compiler to odin if in odin file
vim.api.nvim_create_autocmd("FileType", {
	pattern = "odin",
	group = vim.api.nvim_create_augroup("ag-odin-compiler", { clear = true }),
	callback = function()
		-- ~_ag TODO: Make this default to a simple build script if not script in project
		-- vim.opt_local.makeprg = "odin build src -radlink -error-pos-style:unix -show-timings"

		vim.opt_local.errorformat = {
			"%f:%l:%c: %trror: %m", -- file:line:col: Error: msg
			"%f:%l:%c: %tarning: %m", -- file:line:col: Warning: msg
			"%f:%l:%c: %m",
			"%f(%l:%c) %m", -- default odin style: file(line:col) msg
			"%-G%.%#", -- ignore everything else
		}
	end,
})


vim.keymap.set("n", "<M-m>", function()
	vim.fn.execute({ 'make!', 'copen' })
end, { remap = true })


-- ~_ag NOTE: Configure how Neovim shows diagnostics
vim.diagnostic.config {
	update_in_insert = false,
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	-- Can switch between these as you prefer
	virtual_text = true,   -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float {
				bufnr = bufnr,
				scope = 'cursor',
				focus = false,
			}
		end,
	},
}

-- Force the Error text to be bright red
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#FF0000", bold = true })

-- ///////////////////////////////////////////////////
-- ~_ag: mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


vim.keymap.set('i', '<C-BS>', '<C-W>', {})
vim.keymap.set('i', '<C-z>', function() vim.cmd [[ undo ]] end, {})
--highlight move with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("i", "<C-c>", "<Esc>")
--remove highligh from search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })



--=================================================
-- ~_ag NOTE: comment utils
do
	local set_comment = function(TAG)
		local t              = TAG or ''
		local user_name      = '_ag'
		local insert_command = 'normal! i~' .. user_name .. ' ' .. t .. ': '
		vim.cmd(insert_command)
		vim.cmd [[ normal gcc$]]
	end
	vim.keymap.set("n", "<M-y>", function() set_comment() end, { remap = true })
	vim.keymap.set("n", "<M-t>", function() set_comment('TODO') end, { remap = true })
	vim.keymap.set("n", "<M-n>", function() set_comment('NOTE') end, { remap = true })
	vim.keymap.set("n", "<M-t>t", function() set_comment('FIX') end, { remap = true })
	vim.keymap.set("i", "<M-y>", function() set_comment() end, { remap = true })
	vim.keymap.set("i", "<M-t>", function() set_comment('TODO') end, { remap = true })
	vim.keymap.set("i", "<M-n>", function() set_comment('NOTE') end, { remap = true })
	vim.keymap.set("i", "<M-t>t", function() set_comment('FIX') end, { remap = true })
end

do
	local comment_out_line = function()
		local c = vim.api.nvim_win_get_cursor(0)
		vim.cmd [[ normal gcc]]
		-- ~_ag TODO:setting cursor 3 character fowards but it could be more depending on 
		-- 						what the comment string is should dynamic in the future
		vim.api.nvim_win_set_cursor(0, { c[1], c[2] + 3 })
	end
	vim.keymap.set("i", "<C-/>", comment_out_line, { remap = true })
	vim.keymap.set("n", "<C-/>", 'gcc', { remap = true })
	vim.keymap.set("v", "<C-/>", 'gc', { remap = true })
end

-- ~_ag NOTE: end ofcomment utils
--=================================================


---/////////////////////////////////////////////////////////////////////////////////////////////
--- ~!_ag: these keybinds eventually should give a lot of movment options
--- 			 when in insert mode or normal mode and when using the arrow keys
--- 			
--- 			 note: a combination of vim and 4coder motions
---

--~_ag NOTE: DYNAMIC FILE HOPPING
--					============================================
do
	local function switch_source_header()
		local prefered_src_ext = 'cc'
		local prefered_hed_ext = 'h'
		local source_exts = { "c", "cc", "cpp", "cxx" }
		local header_exts = { "h" }
		local file = vim.api.nvim_buf_get_name(0)

		if file ~= "" then
			local base      = vim.fn.fnamemodify(file, ":r")
			local ext       = vim.fn.fnamemodify(file, ":e")
			local name      = vim.fn.fnamemodify(file, ":t:r")
			local is_source = vim.tbl_contains(source_exts, ext)
			local is_header = vim.tbl_contains(header_exts, ext)
			if (is_source or is_header) then
				local targets
				if is_source then
					targets = header_exts
				else
					targets = source_exts
				end

				--~_ag: at this point we either find or create the counter path
				local counterpart_path = ''
				local new_header = ''
				for _, e in pairs(targets) do
					local path = base .. "." .. e
					if vim.fn.filereadable(path) == 1 or vim.fn.bufexists(path) == 1 then
						counterpart_path = path -- we found the file we want we'll jump to it
						break
					end
				end

				if counterpart_path == '' then
					if is_source then
						counterpart_path = base .. '.' .. prefered_hed_ext
						new_header = name:upper():gsub("[^%w]", "_") .. "_H"
					else
						counterpart_path = base .. '.' .. prefered_src_ext
					end
				end

				-- ~_ag: at this point we ahve a counterpart_path always
				vim.cmd.edit(vim.fn.fnameescape(counterpart_path))

				if new_header ~= '' then
					vim.api.nvim_buf_set_lines(0, 0, -1, false, {
						"#if!defined(" .. new_header .. ")", "", "",
						"#define " .. new_header,
						"#endif // " .. new_header,
					})
					vim.api.nvim_win_set_cursor(0, { 1, 0 })
				end
			end
		end
	end

	vim.keymap.set("n", "<M-2>", switch_source_header, {
		desc = "Switch between source and header",
	})
end

--~_ag NOTE: DYNAMIC FILE HOPPING END
--					============================================

--=================================================
-- ~_ag NOTE: rad debugger integration
do
	-- ~_ag TODO: set per project or eventually make it a full plugin to interact with the debugger	
	-- 						For now just use the run to line command
	local raddbg = "raddbg" -- or full path, e.g. "C:/tools/raddbg/raddbg.exe"
	-- ~_ag NOTE:this is a windows only function  noop if not windows
	local rad_running = function()
		-- tasklist is win32; returns true if raddbg.exe is alive
		local out = vim.fn.system('tasklist /FI "IMAGENAME eq raddbg.exe" /NH')
		return out:find("raddbg.exe", 1, true) ~= nil
	end

	if  OS_NAME ~= 'Windows_NT' then
		rad_running =  function ()
			vim.notify("WINDOWS ONLY UTILITY NOT SETUP FOR ANYTHING ELSE", vim.log.levels.ERROR)
		end
	end

	-- start / continue

	-- ~_ag :Run to line
	local function run_to_line()
		if rad_running() then
			local line = vim.fn.getcurpos(0)[2]
			local name = vim.fn.expand("%")
			-- ~_ag TODO: set path per project
			local dbg_cmd = '--ipc run_to_line ' .. 'w:/' .. name .. ':' .. line
			local cmd = { raddbg, dbg_cmd }
			vim.notify('cmd ran: ' .. dbg_cmd)
			vim.fn.jobstart(cmd, { detach = true })
		else
			vim.notify("raddbg not running", vim.log.levels.WARN)
		end
	end
	vim.keymap.set("n", "<F9>", run_to_line, { desc = "raddbg run to line" })
	cmd_palette.add('raddbg: run to line', run_to_line)

	-- ~_ag :start running
	local function start_debugger()
		if rad_running() then
			local dbg_cmd = '--ipc run'
			local cmd = { raddbg, dbg_cmd }
			vim.fn.jobstart(cmd, { detach = true })
		else
			vim.notify("raddbg not running", vim.log.levels.WARN)
		end
	end
	vim.keymap.set("n", "<F6>", start_debugger, { desc = "raddbg run/continue" })
	cmd_palette.add('raddbg: start running target', start_debugger)

	-- ~_ag :kill all running
	local function kill_all_dbg()
		if rad_running() then
			local dbg_cmd = '--ipc kill_all'
			local cmd = { raddbg, dbg_cmd }
			vim.fn.jobstart(cmd, { detach = true })
		else
			vim.notify("raddbg not running", vim.log.levels.WARN)
		end
	end
	vim.keymap.set("n", "<S-F6>", kill_all_dbg, { desc = "raddbg run/continue" })
	cmd_palette.add('raddbg: kill all', kill_all_dbg)
end

-- ~_ag NOTE: end of rad debugger integration
--=================================================


--~_ag: move between begingin and end of a line
vim.keymap.set('n', '<C-h>', '<home>', { desc = 'move cursor to start of line' })
vim.keymap.set('n', '<C-l>', '<end>', { desc = 'move cursor to end of line' })
vim.keymap.set('n', '<C-Left>', '<home>', { desc = 'move cursor to start of line' })
vim.keymap.set('n', '<C-Right>', '<end>', { desc = 'move cursor to end of line' })

--~_ag: change behavior of arrows:
vim.keymap.set('n', '<Right>', '<Space>', { desc = 'move cursor to end of line' })
vim.keymap.set('n', '<Left>', '<Backspace>', { desc = 'move cursor to end of line' })

--~_ag: move up/down jumpining between white spaces
vim.keymap.set('n', '<C-j>', '}', { desc = 'move cursor paragraph down' })
vim.keymap.set('n', '<C-k>', '{', { desc = 'move cursor paragraph up' })

vim.keymap.set('n', '<C-Down>', '}', { desc = 'move cursor paragraph down' })
vim.keymap.set('n', '<C-Up>', '{', { desc = 'move cursor paragraph up' })

vim.keymap.set('v', '<C-j>', '}', { desc = 'move cursor paragraph down', remap = true })
vim.keymap.set('v', '<C-k>', '{', { desc = 'move cursor paragraph up', remap = true })

--~_ag: move using quick fix
vim.keymap.set('n', '<M-q>', vim.diagnostic.setqflist, { desc = 'Put diagnostics into quickfix list' })
vim.keymap.set('n', '<M-j>', '<CMD>cnext<CR>', { desc = 'move to next item in quick list' })
vim.keymap.set('n', '<M-k>', '<CMD>cprev<CR>', { desc = 'move to prev item in quick list' })


-- ///////////////////////////////////////////////////
-- ~_ag: autocmds
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('kikckstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- ///////////////////////////////////////////////////
-- ~_ag: random stuff i wanna run on startup
-- vim.cmd([[vs]])

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- Setup lazy.nvim
require("lazy").setup({
	-- ///////////////////////////////////////////////////
	-- ~_ag: plugins start here:
	--- ~_ag TODO: create fuzzy_search_buffer(s) tags
	spec = {
		-- ~_ag NOTE: mark@themes
		{ "vague-theme/vague.nvim",   lazy = true },
		{ 'ellisonleao/gruvbox.nvim', lazy = true },
		{ "wtfox/luna.nvim",          lazy = true },
		{ "slugbyte/lackluster.nvim", lazy = false, },
		{
			"zenbones-theme/zenbones.nvim",
			dependencies = "rktjmp/lush.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				vim.g.zenbones_darken_comments = 45
				vim.cmd.colorscheme('zenbones')
			end
		},
		-- ~_ag NOTE: mark@themes@end

		-- ~_ag NOTE: show line indents
		{
			"lukas-reineke/indent-blankline.nvim",
			main = 'ibl',
			opts = {},
			enabled = false
		},

		{
			'nvim-treesitter/nvim-treesitter',
			lazy = false,
			build = ':TSUpdate',
			config = function()
				local ts = require('nvim-treesitter')

				ts.setup({})
				ts.install { 'c', 'cpp', 'lua', 'javascript', 'typescript', 'odin' }
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "c", "cpp", "lua", "javascript", "typescript", "odin" },
					callback = function()
						vim.treesitter.start()
						-- ~_ag TESTING:  indent with treesitter  
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end,
				})
			end,
		},

		{
			"nvim-telescope/telescope.nvim",
			version = "*",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				local builtin = require("telescope.builtin")
				local make_entry = require("telescope.make_entry")
				local entry_display = require("telescope.pickers.entry_display")

				local displayer = entry_display.create({
					separator = " ",
					items = { { width = 40 }, { width = 10 }, { remaining = true } },
				})

				--// ~_ag: makes anon structs/unions show up as grey when looks at buffer symbols
				vim.keymap.set("n", "<C-i>", function()
					local opts = { symbols = { "function", "struct", "class", "enum" } }
					local maker = make_entry.gen_from_lsp_symbols(opts)

					opts.entry_maker = function(item)
						local entry = maker(item)
						entry.display = function(e)
							local hl = e.symbol_name:match("^%(") and "Comment"
							or e.symbol_type == "Function" and "Function"
							or "Normal"
							return displayer({
								{ e.symbol_name,         hl },
								{ e.symbol_type:lower(), "Comment" },
								{ ":" .. e.lnum,         "LineNr" },
							})
						end
						return entry
					end
					builtin.lsp_document_symbols(opts)
				end, { desc = "Top-level symbols" })

				vim.keymap.set("n", "<C-o>", builtin.find_files, { desc = "Telescope find files" })

				do
					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")


					local function command_palette()
						local items = vim.list_extend({}, cmd_palette.items)
						for builtin_name, proc in pairs(builtin) do
							if type(proc) == 'function' then
								table.insert(items, { name = "telescope: " .. builtin_name, fn = proc })
							end
						end
						pickers.new({}, {
							prompt_title = 'command palette',
							finder = finders.new_table({
								results = items,
								entry_maker = function(item)
									return { value = item, display = item.name, ordinal = item.name }
								end,
							}),
							sorter = conf.generic_sorter({}),
							attach_mappings = function(prompt_bufnr)
								actions.select_default:replace(function()
									local sel = action_state.get_selected_entry()
									actions.close(prompt_bufnr)
									if sel then vim.schedule(function() sel.value.fn() end) end
								end)
								return true
							end,
						}):find()
					end

					vim.keymap.set("n", "<C-x>", command_palette, { desc = "Telescope find files" })
				end


				--~_ag TODO: implement custon command palette
				-- this will be part of command palette:vim.keymap.set('n', 'dm',function() vim.cmd('delmarks!') end, {remap=true})

				vim.keymap.set("n", "<C-g>", builtin.current_buffer_fuzzy_find, { desc = "Telescope live grep" })
				vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			end,
		},

		{
			"folke/todo-comments.nvim",
			lazy = false,
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require('todo-comments').setup({
					signs = true,      -- show icons in the signs column
					sign_priority = 8, -- sign priority
					-- keywords recognized as todo comments
					keywords = {
						--- // ~_ag NHM:	Loremimfs sdoif nwfwoij !! 9--= r902
						NHM  = { icon = "⚙️", color = "#0d438b", alt = {}, },
						--- // ~_ag FIX:	Loremimfs sdoif nwfwoij !! 9--= r902
						FIX  = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, },
						--- // ~_ag TODO:	Loremimfs sdoif nwfwoij !! 9--= r902
						TODO = { icon = " ", color = "#2d4720", alt = {}, },
						--- // ~_ag HACK:	Loremimfs sdoif nwfwoij !! 9--= r902
						HACK = { icon = " ", color = "#FBBF24", alt = { 'IMPORTANT', 'STUDY' }, },
						--- // ~_ag WARN:	Loremimfs sdoif nwfwoij !! 9--= r902
						WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
						--- // ~_ag PERF:	Loremimfs sdoif nwfwoij !! 9--= r902
						PERF = { icon = " ", color = "#7c3aed", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
						--- // ~_ag NOTE:	Loremimfs sdoif nwfwoij !! 9--= r902
						NOTE = { icon = " ", color = "info", alt = { "INFO" } },
						--- // ~_ag FUNC:	Loremimfs sdoif nwfwoij !! 9--= r902
						FUNC = { icon = " ", color = "info", },
						--- // ~_ag TEST:	Loremimfs sdoif nwfwoij !! 9--= r902
						TEST = { icon = "⏲ ", color = "#10b981", alt = { "TESTING", "ASSERT", "PASSED", "FAILED" } },
					},
					merge_keywords = true,
				})
				cmd_palette.add('todo quickfix', function() require('todo-comments.search').setqflist({}) end)
			end
		},


		{
			'saghen/blink.cmp',
			dependencies = { 'rafamadriz/friendly-snippets' }, -- optional: provides snippets for the snippet source
			version = '1.*',
			opts = {
				keymap = { preset = 'enter' },
				appearance = {
					nerd_font_variant = 'mono'
				},
				completion = {
					documentation = { auto_show = true },
					accept = { auto_brackets = {enabled = true}, },
					menu = { auto_show = true },
				},
				sources = {
					default = { 'lsp', 'path', 'snippets', 'buffer' },
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" }
		},
		--- // ~_ag TODO: Test if marks can be use to implement 4coders mark/cursor duo
		--- // ~_ag: better marks etc
		{
			"chentoast/marks.nvim",
			event = "VeryLazy",
			opts = {}
		},

		{
			'neovim/nvim-lspconfig',
			dependencies =
				{
					-- // ~_ag: tells lua lsp where to find the vim specific stuff
					'folke/lazydev.nvim',
					ft = 'lua',
					opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } }, } }
				},
			config = function()
				-- ///////////////////////////////////////////////////
				-- // ~_ag: these LSP must be installed and accessible in the path
				-- //  			or else you'll get an error on startup duhh
				vim.lsp.config('clangd', {})
				vim.lsp.config('lua_ls', {})
				vim.lsp.config('ts_ls', {})
				vim.lsp.config('ols', {})
				vim.lsp.enable 'clangd'
				vim.lsp.enable 'lua_ls'
				vim.lsp.enable 'ts_ls'
				vim.lsp.enable 'ols'
				--<C-]> jumps to definition
				--<C-t> jumps back from where you came from
			end,
		}

		-- ~_ag: plugins end here:
		-- ///////////////////////////////////////////////////
	},
	install = { colorscheme = { "vague" } },
	checker = { enabled = true },
	change_detection = { notify = false },
}
)
