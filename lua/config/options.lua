-- -- Basic configs for neovim
local opt = vim.opt

-- Buffer window
opt.colorcolumn = "80"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.textwidth = 0
opt.wrap = false

-- Encoding
opt.encoding = "utf8"
opt.fileencoding = "utf8"

-- Theme
opt.syntax = "ON"
opt.termguicolors = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.showcmd = true

-- Whitespace
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Clipboard synchronysation
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- Ask for confirmation before exit without saving
opt.confirm = true

-- Highlights line under cursor
opt.cursorline = true

-- Folds
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  diff = "╱",
  -- fold = " ",
  -- foldsep = " ",
  -- eob = " ",
}
opt.foldlevel = 99
opt.foldmethod = "indent"

-- Format options
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.inccommand = "nosplit"
opt.jumpoptions = "view"

-- Always shows status line
opt.laststatus = 3

-- Shows invisible characters
opt.list = true

-- Popup menu
opt.pumblend = 10
opt.pumheight = 10

-- Saved options open buffer closing
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Shifting "<<, >>" goes to nearest shiftwidth
opt.shiftround = true

-- Wrapping
opt.linebreak = true

-- Taken care of by statusline
opt.showmode = false

-- Keymap timeout
opt.timeoutlen = 300

-- Remember undo after closing file
opt.undofile = true
opt.undolevels = 2000
opt.updatetime = 200
opt.wildmode = "longest:full,full"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Stores cursor info, command history, search history and last help window
opt.shada = "'1000,<50,s10,h"
opt.hidden = true

-- -- For plugins

-- Formatting
vim.b.autoformat = false

-- Root specification
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
