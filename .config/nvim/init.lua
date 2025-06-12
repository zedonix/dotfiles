-- Leader Key Setup
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Netrw Configuration
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3

-- UI Configuration
vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_transparent_background = 1

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
vim.opt.scrolloff = 4
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.confirm = true
vim.opt.clipboard = 'unnamedplus'

-- Disabling unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Highlight on Yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Keybindings
vim.keymap.set('n', '<Leader>bi', '<cmd>ls<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>bd', '<cmd>bd<CR>', { noremap = true, silent = true })

vim.keymap.set('n', "'", '`', { noremap = true })
vim.keymap.set('n', '`', "'", { noremap = true })
vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' })

-- Plugin Setup: lazy.nvim
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
        main = 'nvim-treesitter.configs',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    'bash',
                    'python',
                    'c',
                    'diff',
                    'html',
                    'lua',
                    'luadoc',
                    'markdown',
                    'markdown_inline',
                    'query',
                    'vim',
                    'vimdoc',
                },
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = false, disable = { 'vimwiki' } },
                indent = { enable = true },
            }
        end,
    },

    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },

    {
        'neovim/nvim-lspconfig',
        config = function()
            vim.lsp.enable 'pyright'
            vim.lsp.enable 'ts_ls'
            vim.lsp.enable 'bashls'
            vim.lsp.enable 'lua_ls'
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
                    map('grr', function()
                        require('fzf-lua').lsp_references()
                    end, '[G]oto [R]eferences')
                    map('gri', function()
                        require('fzf-lua').lsp_implementations()
                    end, '[G]oto [I]mplementation')
                    map('grd', function()
                        require('fzf-lua').lsp_definitions()
                    end, '[G]oto [D]efinition')
                    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    map('gO', function()
                        require('fzf-lua').lsp_document_symbols()
                    end, 'Open Document Symbols')
                    map('gW', function()
                        require('fzf-lua').lsp_workspace_symbols()
                    end, 'Open Workspace Symbols')
                    map('grt', function()
                        require('fzf-lua').lsp_typedefs()
                    end, '[G]oto [T]ype Definition')

                    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if
                        client
                        and client_supports_method(
                            client,
                            vim.lsp.protocol.Methods.textDocument_documentHighlight,
                            event.buf
                        )
                    then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if
                        client
                        and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
                    then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                    vim.diagnostic.config {
                        severity_sort = true,
                        float = { border = 'rounded', source = 'if_many' },
                        underline = { severity = vim.diagnostic.severity.ERROR },
                        signs = vim.g.have_nerd_font
                                and {
                                    text = {
                                        [vim.diagnostic.severity.ERROR] = '󰅚 ',
                                        [vim.diagnostic.severity.WARN] = '󰀪 ',
                                        [vim.diagnostic.severity.INFO] = '󰋽 ',
                                        [vim.diagnostic.severity.HINT] = '󰌶 ',
                                    },
                                }
                            or {},
                        virtual_text = {
                            source = 'if_many',
                            spacing = 2,
                            format = function(diagnostic)
                                local diagnostic_message = {
                                    [vim.diagnostic.severity.ERROR] = diagnostic.message,
                                    [vim.diagnostic.severity.WARN] = diagnostic.message,
                                    [vim.diagnostic.severity.INFO] = diagnostic.message,
                                    [vim.diagnostic.severity.HINT] = diagnostic.message,
                                }
                                return diagnostic_message[diagnostic.severity]
                            end,
                        },
                    }
                end,
            })
        end,
    },

    -- Gruvbox Material
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
        init = function()
            vim.g.vimwiki_list = {
                {
                    path = '~/vimwiki/',
                    syntax = 'markdown',
                    ext = 'md',
                },
            }
            vim.g.vimwiki_global_ext = 1
            vim.g.vimwiki_ext2syntax = { ['.md'] = 'markdown' }
        end,
        event = 'BufEnter *.md',
        cmd = { 'VimwikiIndex', 'VimwikiDiaryIndex' },
        keys = { '<leader>ww', '<leader>wi', '<Leader>w<Leader>w' },
    },

    -- mini.completion
    {
        'echasnovski/mini.completion',
        version = false,
        config = function()
            require('mini.completion').setup()
        end,
    },

    -- mini.snippets
    {
        'echasnovski/mini.snippets',
        version = false,
        config = function()
            require('mini.snippets').setup()
            -- Optional: Define your snippets here or in a separate Lua file
        end,
    },

    -- mini.statusline
    {
        'echasnovski/mini.statusline',
        version = false,
        config = function()
            local statusline = require 'mini.statusline'
            statusline.setup { use_icons = vim.g.have_nerd_font }
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                local col = vim.fn.col '.'
                local total_col = vim.fn.col '$' - 1
                return string.format('%d:%d', col, total_col)
            end
        end,
    },

    -- mini.icons
    {
        'echasnovski/mini.icons',
        version = false,
        config = function()
            require('mini.icons').setup()
        end,
    },

    -- mini.move
    {
        'echasnovski/mini.move',
        version = false,
        config = function()
            require('mini.move').setup()
        end,
    },

    -- mini.ai
    {
        'echasnovski/mini.ai',
        version = false,
        config = function()
            require('mini.ai').setup { n_lines = 500 }
        end,
    },

    -- conform
    {
        'stevearc/conform.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_format = 'fallback' }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true }
                if disable_filetypes[vim.bo[bufnr].filetype] then
                    return nil
                else
                    return {
                        timeout_ms = 500,
                        lsp_format = 'fallback',
                    }
                end
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'black' },
                sh = { 'shfmt' },
                javascript = { 'prettier' },
                javascriptreact = { 'prettier' },
            },
        },
    },

    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },

    {
        'chentoast/marks.nvim',
        event = 'VeryLazy',
        opts = {},
    },

    {
        'ibhagwan/fzf-lua',
        dependencies = { 'echasnovski/mini.icons' },
        opts = {},
        -- stylua: ignore
        keys = {
            { '<leader>sh', function() require('fzf-lua').help_tags() end, desc = '[S]earch [H]elp' },
            { '<leader>sk', function() require('fzf-lua').keymaps() end, desc = '[S]earch [K]eymaps' },
            { '<leader>sf', function() require('fzf-lua').files() end, desc = '[S]earch [F]iles' },
            { '<leader>sw', function() require('fzf-lua').grep_cword() end, desc = '[S]earch current [W]ord' },
            { '<leader>sg', function() require('fzf-lua').live_grep() end, desc = '[S]earch by [G]rep' },
            { '<leader>sd', function() require('fzf-lua').diagnostics_document() end, desc = '[S]earch [D]iagnostics' },
            { '<leader>s.', function() require('fzf-lua').oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },
            { '<leader><leader>', function() require('fzf-lua').buffers() end, desc = '[ ] Find existing buffers' },
            { '<leader>sv', function() require('fzf-lua').live_grep({ cwd = '~/vimwiki' }) end, desc = '[S]earch [V]imwiki' }
        },
    },
}
-- require("luasnip").filetype_extend("vimwiki", {"markdown"})
