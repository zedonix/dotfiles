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
-- vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
-- vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
-- vim.api.nvim_set_hl(0, 'NonText', { bg = 'NONE' })
-- vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })

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
    elseif extension == 'sh' then
        Formatter = 'shfmt -w -i 4'
    else
        Formatter = 'echo'
    end
    return string.format('!%s %%', Formatter)
end

-- Keybindings
Map('n', '<Leader>b', '<cmd>ls<CR>')
Map('n', '<Esc>', '<cmd>nohlsearch<CR>')
Map('n', '<Leader>f', '<cmd>:Format<CR>')
Map('n', '<Leader>s', '<cmd>:Format<CR>')
Map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
Map('n', 'j', 'gj')
Map('n', 'k', 'gk')

-- LSP Key Mappings
Map('n', 'gd', '<cmd>vim.lsp.buf.definition<CR>')
Map('n', 'gi', '<cmd>vim.lsp.buf.implementation<CR>')
Map('n', '<Leader>ca', '<cmd>vim.lsp.buf.code_action<CR>')
Map('n', '<Leader>r', '<cmd>vim.lsp.buf.rename<CR>')
Map('n', '<Leader>df', '<cmd>vim.diagnostic.goto_next<CR>')
Map('n', '<Leader>dp', '<cmd>vim.diagnostic.goto_prev<CR>')

-- Format Command
vim.api.nvim_create_user_command('FormatFile', function()
    local command = Format()
    vim.cmd(command)
end, { desc = 'Format the current file' })

-- Plugin Setup
-- Mini.Deps
local path_package = vim.fn.stdpath 'data' .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd 'echo "Installing `mini.nvim`" | redraw'
    local clone_cmd = {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/echasnovski/mini.nvim',
        mini_path,
    }
    vim.fn.system(clone_cmd)
    vim.cmd 'packadd mini.nvim | helptags ALL'
    vim.cmd 'echo "Installed `mini.nvim`" | redraw'
end

require('mini.deps').setup { path = { package = path_package } }
local add = MiniDeps.add

-- Plugin install
add { source = 'sainnhe/gruvbox-material' }

add {
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'master',
    monitor = 'main',
    hooks = {
        post_checkout = function()
            vim.cmd 'TSUpdate'
        end,
    },
}
add {
    source = 'neovim/nvim-lspconfig',
}

-- Initialize Plugins
local now, later = MiniDeps.now, MiniDeps.later

now(function()
    vim.g.gruvbox_material_enable_italic = true
    vim.cmd 'colorscheme gruvbox-material'
end)
now(function()
    require('mini.statusline').setup()
end)
now(function()
    require('mini.icons').setup()
end)

later(function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = { 'lua', 'vimdoc', 'python', 'bash' },
        highlight = { enable = true },
    }
end)

-- LSP
later(function()
    vim.lsp.enable 'pyright'
    vim.lsp.enable 'bashls'
end)
