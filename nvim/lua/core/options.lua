local options = {
    ai = true,
    autoindent = true,
    autowrite = true,
    background = 'dark',
    backspace = 'indent,eol,start',
    backup = false, -- creates a backup file
    breakindent = true,
    clipboard = 'unnamedplus', -- allows neovim to access the system clipboard
    cmdheight = 1, -- more space in the neovim command line for displaying messages
    completeopt = 'menu,menuone,noselect', -- mostly just for cmp
    conceallevel = 0, -- so that `` is visible in markdown files
    confirm = true, -- Confirm to save changes before exiting modified buffer
    cursorline = true, -- highlight the current line
    expandtab = true, -- convert tabs to spaces
    fileencoding = 'utf-8', -- the encoding written to a file
    formatoptions = 'jcroqlnt', -- tcqj
    grepformat = '%f:%l:%c:%m',
    grepprg = 'rg --vimgrep',
    hlsearch = false, -- highlight all matches on previous search pattern
    ignorecase = true, -- ignore case in search patterns
    inccommand = 'split', -- preview incremental substitute
    incsearch = true,
    laststatus = 3,
    list = false,
    -- listchars = { trail = '', tab = '', nbsp = '_', extends = '>', precedes = '<' }, -- highlight
    mouse = 'a', -- allow the mouse to be used in neovim
    number = true, -- set numbered lines
    -- numberwidth = 4,        -- set number column width to 2 {default 4}
    pumblend = 0, -- Popup blend
    pumheight = 10, -- pop up menu height
    relativenumber = false, -- set relative numbered lines
    scrolloff = 8, -- is one of my fav
    sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal',
    shiftround = true, -- Round indent
    shiftwidth = 4, -- the number of spaces inserted for each indentation
    showcmd = false,
    showmode = true, -- we don't need to see things like -- INSERT -- anymore
    showtabline = 0, -- always show tabs
    si = true,
    sidescrolloff = 8,
    signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
    smartcase = true, -- smart case
    smartindent = true, -- make indenting smarter again
    smarttab = true,
    softtabstop = 4,
    splitbelow = true, -- force all horizontal splits to go below current window
    splitright = true, -- force all vertical splits to go to the right of current window
    swapfile = false, -- creates a swapfile
    tabstop = 4, -- insert 2 spaces for a tab
    termguicolors = true, -- set term gui colors (most terminals support this)
    timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true, -- enable persistent undo
    undodir = vim.fn.expand('~/.config/nvim/undo'),
    undolevels = 10000,
    updatetime = 50, -- faster completion (4000ms default)
    wildmenu = true, -- wildmenu
    wildmode = 'longest:full,full', -- Command-line completion mode
    winminwidth = 5, -- Minimum window width
    wrap = false, -- display lines as one long line
    writebackup = false, -- do not edit backups
}

---------------------------------------------------------------------------------------------------
-- Setup python path
---------------------------------------------------------------------------------------------------
local possible_python_paths = {
    -- Extend the list for possible python path. Will use the 1st possible one
    os.getenv('HOME') .. '/qa/autotests_jm_landing/.venv/bin/python3', -- Python3's venv (dev)
    -- os.getenv("HOME") .. "/opt/anaconda3/envs/dev/bin/python",          -- MacOS's conda (dev)
    -- os.getenv("HOME") .. "/anaconda3/envs/dev/bin/python",              -- Linux's conda (dev)
    -- os.getenv('HOME') .. '/.conda/envs/dev/bin/python',                 -- Linux's alternative conda (dev)
    -- os.getenv("HOME") .. "/.pyenv/shims/python",                        -- pyenv's default path
    '/usr/bin/python3', -- System default python3
    '/usr/bin/python', -- System default python
}
for _, python_path in pairs(possible_python_paths) do
    if io.open(python_path, 'r') ~= nil then
        vim.g.python3_host_prog = python_path
        break
    end
end

-- vim.g.python3_host_prog = '~/venvs/neovim/bin/python'

---------------------------------------------------------------------------------------------------
-- Deactivate unused providers
---------------------------------------------------------------------------------------------------
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

vim.opt.shortmess:append({ W = true, I = true, c = true })

if vim.fn.has('nvim-0.9.0') == 1 then
    vim.opt.splitkeep = 'screen'
    vim.opt.shortmess:append({ C = true })
end

for k, v in pairs(options) do
    vim.opt[k] = v
end
