local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.scrolloff = 8
o.wrap = false
o.showmode = false

o.splitright = true
o.splitbelow = true

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true

o.undofile = true
o.updatetime = 250
o.timeoutlen = 400
o.clipboard = "unnamedplus"
o.mouse = "a"
o.confirm = true
o.completeopt = { "menu", "menuone", "noselect" }
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }

-- Clean look
o.winborder = "rounded" -- rounded borders on every floating window
o.laststatus = 3 -- one global statusline
o.fillchars = {
  eob = " ", fold = " ", foldopen = "\u{f078}", foldclose = "\u{f054}",
  -- heavy lines so splits (explorer | editor, editor / terminal) stand out
  vert = "┃", horiz = "━", horizup = "┻", horizdown = "┳",
  vertleft = "┫", vertright = "┣", verthoriz = "╋",
}
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.pumheight = 12
