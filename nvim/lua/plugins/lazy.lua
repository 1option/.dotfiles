local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

local status_ok, lazy = pcall(require, 'lazy')
if not status_ok then
    return
end

local plugins = require('plugins.list').plugins

lazy.setup({
    root = vim.fn.stdpath('data') .. '/lazy',
    defaults = { lazy = true },

    spec = plugins,
    lockfile = vim.fn.stdpath('config') .. '/lua/plugins/lock.json',
    concurrency = 8,
    install = { missing = true, colorscheme = { 'nano-theme' } },

    git = {
        log = { '--since=3 days ago' },
        timeout = 120,

        url_format = 'https://github.com/%s.git',
        filter = true,
    },

    ui = {
        size = { width = 0.9, height = 0.8 },
        wrap = true,
        border = 'rounded',
        backdrop = 100,
        -- title = 'Lazy',
        title_pos = 'center',
        browser = nil,
        throttle = 20,
        pills = true,
        icons = {
            cmd = ' ',
            config = '',
            event = ' ',
            favorite = ' ',
            ft = ' ',
            init = ' ',
            import = ' ',
            keys = ' ',
            lazy = '󰒲 ',
            loaded = '●',
            not_loaded = '○',
            plugin = ' ',
            runtime = ' ',
            require = '󰢱 ',
            source = ' ',
            start = ' ',
            task = '✔ ',
            list = {
                '●',
                '➜',
                '★',
                '‒',
            },
        },
    },

    diff = { cmd = 'git' },
    checker = { enabled = false, concurrency = nil, notify = true, frequency = 3600 },
    change_detection = { enabled = true, notify = true },
    performance = {
        cache = { enabled = true },
        reset_packpath = true,
        rtp = {

            reset = true,
            paths = {},

            disabled_plugins = {
                'gzip',
                'tarPlugin',
                'zipPlugin',
                'tohtml',
                -- 'tutor',
                -- 'matchit',
                -- 'matchparen',
                'netrwPlugin',
            },
        },
    },
})
