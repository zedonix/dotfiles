-- Leader Key Setup
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Netrw Configuration
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3

-- UI Configuration
vim.g.have_nerd_font = true
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_transparent_background = 1

-- Transparent Background Setup
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NonText', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })

-- Editor Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = false
vim.opt.scrolloff = 18
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Clipboard Setup
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

-- Highlight on Yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Keymap Setup
function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Formatting Function
function Format()
    local extension = vim.bo.filetype
    if extension == 'lua' then
        Formatter = 'stylua'
    elseif extension == 'python' then
        Formatter = 'black'
    else
        Formatter = 'echo'
    end
    return string.format('!%s %%', Formatter)
end

-- Keybindings
Map('n', '<Leader>b', '<cmd>ls<CR>')
Map('n', '<Leader>f', '<cmd>:18Lex<CR>')
Map('n', '<Esc>', '<cmd>nohlsearch<CR>')
Map('n', '<Leader>s', '<cmd>:FormatFile<CR>')
Map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
Map('n', 'j', 'gj')
Map('n', 'k', 'gk')

-- Format Command
vim.api.nvim_create_user_command('FormatFile', function()
    local command = Format()
    vim.cmd(command)
end, { desc = 'Format the current file' })

-- Plugin Setup
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'lua', 'python', 'bash' },
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
            }
        end,
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require 'lspconfig'
            lspconfig.pyright.setup {}

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<space>f', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)
                end,
            })
        end,
    },
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_enable_italic = true
            vim.cmd.colorscheme 'gruvbox-material'
        end,
    },
    {
        'vimwiki/vimwiki',
        event = 'BufEnter *.md',
        init = function()
            vim.g.vimwiki_list = {
                {
                    path = '~/vimwiki/',
                    syntax = 'markdown',
                    ext = 'md',
                },
            }
            vim.g.vimwiki_global_ext = 0
        end,
        keys = { "<leader>ww", "<leader>wt" },
    },
}
