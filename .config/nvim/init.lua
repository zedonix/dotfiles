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
vim.o.termguicolors = true
vim.o.background = 'dark'
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
vim.opt.scrolloff = 18
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.o.confirm = true

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

-- Formatting Function
function Format()
    local extension = vim.bo.filetype
    local Formatter
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
vim.keymap.set('n', '<Leader>bi', '<cmd>ls<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>bd', '<cmd>bd<CR>', { noremap = true, silent = true })

vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' })

-- Format Command
vim.api.nvim_create_user_command('FormatFile', function()
    local command = Format()
    vim.cmd(command)
end, { desc = 'Format the current file' })

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
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
            }
        end,
    },

    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            -- The easiest way to use Telescope, is to start by doing something like:
            --  :Telescope help_tags
            --
            -- After running this command, a window will open up and you're able to
            -- type in the prompt window. You'll see a list of `help_tags` options and
            -- a corresponding preview of the help.
            --
            -- Two important keymaps to use while in Telescope are:
            --  - Insert mode: <c-/>
            --  - Normal mode: ?
            --
            -- This opens a window that shows you all of the keymaps for the current
            -- Telescope picker. This is really useful to discover what Telescope can
            -- do as well as how to actually do it!

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup {
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            }

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            -- Slightly advanced example of overriding default behavior and theme
            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = '[/] Fuzzily search in current buffer' })

            -- It's also possible to pass additional configuration options.
            --  See `:help telescope.builtin.live_grep()` for information about particular keys
            vim.keymap.set('n', '<leader>s/', function()
                builtin.live_grep {
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Files',
                }
            end, { desc = '[S]earch [/] in Open Files' })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
                builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = '[S]earch [N]eovim files' })
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
        dependencies = {
            'saghen/blink.cmp',
        },
        config = function()
            vim.lsp.enable 'pyright'
            vim.lsp.enable 'texlab'
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
                    map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                    map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

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

                    -- LSP servers and clients are able to communicate to each other what features they support.
                    --  By default, Neovim doesn't support everything that is in the LSP specification.
                    --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
                    --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
                    local capabilities = require('blink.cmp').get_lsp_capabilities()
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
        end,
        cmd = { 'VimwikiIndex', 'VimwikiDiaryIndex' },
        keys = { '<leader>ww', '<leader>wi', '<Leader>w<Leader>w' },
    },

    -- texpresso
    {
        'let-def/texpresso.vim',
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

    -- mini.surround
    {
        'echasnovski/mini.surround',
        version = false,
        config = function()
            require('mini.surround').setup()
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

    -- mini.jump
    {
        'echasnovski/mini.jump',
        version = false,
        config = function()
            require('mini.jump').setup()
        end,
    },

    -- mini.jump2d
    -- {
    --     'echasnovski/mini.jump2d',
    --     version = false,
    --     config = function()
    --         require('mini.jump2d').setup()
    --     end,
    -- },

    -- neotree
    -- {
    --     'nvim-neo-tree/neo-tree.nvim',
    --     dependencies = {
    --         'nvim-lua/plenary.nvim',
    --         'MunifTanjim/nui.nvim',
    --     },
    --     keys = {
    --         {
    --             '<leader>e',
    --             function()
    --                 require('neo-tree.command').execute { toggle = true, dir = vim.loop.cwd() }
    --             end,
    --             desc = 'Toggle Neo-tree (cwd)',
    --         },
    --     },
    --     opts = {
    --         window = {
    --             position = 'left',
    --             mappings = {
    --                 ['<leader>e'] = 'toggle',
    --             },
    --         },
    --         filesystem = {
    --             follow_current_file = { enabled = true },
    --             use_libuv_file_watcher = true,
    --         },
    --     },
    -- },

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
                -- You can use 'stop_after_first' to run the first available formatter from the list
                -- javascript = { "prettierd", "prettier", stop_after_first = true },
            },
        },
    },

    { -- Autocompletion
        'saghen/blink.cmp',
        event = 'VimEnter',
        version = '1.*',
        dependencies = {
            -- Snippet Engine
            {
                'L3MON4D3/LuaSnip',
                version = '2.*',
                build = (function()
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                        return
                    end
                    return 'make install_jsregexp'
                end)(),
                dependencies = {
                    -- `friendly-snippets` contains a variety of premade snippets.
                    --    See the README about individual language/framework/plugin snippets:
                    --    https://github.com/rafamadriz/friendly-snippets
                    -- {
                    --   'rafamadriz/friendly-snippets',
                    --   config = function()
                    --     require('luasnip.loaders.from_vscode').lazy_load()
                    --   end,
                    -- },
                },
                opts = {},
            },
            'folke/lazydev.nvim',
        },
        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            keymap = {
                -- 'default' (recommended) for mappings similar to built-in completions
                --   <c-y> to accept ([y]es) the completion.
                --    This will auto-import if your LSP supports it.
                --    This will expand snippets if the LSP sent a snippet.
                -- 'super-tab' for tab to accept
                -- 'enter' for enter to accept
                -- 'none' for no mappings
                --
                -- For an understanding of why the 'default' preset is recommended,
                -- you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                --
                -- All presets have the following mappings:
                -- <tab>/<s-tab>: move to right/left of your snippet expansion
                -- <c-space>: Open menu or open docs if already open
                -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
                -- <c-e>: Hide menu
                -- <c-k>: Toggle signature help
                --
                -- See :h blink-cmp-config-keymap for defining your own keymap
                preset = 'default',

                -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
            },

            completion = {
                -- By default, you may press `<c-space>` to show the documentation.
                -- Optionally, set `auto_show = true` to show the documentation after a delay.
                documentation = { auto_show = false, auto_show_delay_ms = 500 },
            },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'lazydev' },
                providers = {
                    lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
                },
            },

            snippets = { preset = 'luasnip' },

            -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
            -- which automatically downloads a prebuilt binary when enabled.
            --
            -- By default, we use the Lua implementation instead, but you may enable
            -- the rust implementation via `'prefer_rust_with_warning'`
            --
            -- See :h blink-cmp-config-fuzzy for more information
            fuzzy = { implementation = 'lua' },

            -- Shows a signature help window while you type arguments for a function
            signature = { enabled = true },
        },
    },
}
