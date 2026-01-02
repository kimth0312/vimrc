-- ~/.config/nvim/init.lua

-----------------------------------------------------------
-- 1. 전역 설정 (Leader Key)
-----------------------------------------------------------
vim.g.mapleader = " "
local opt = vim.opt

-----------------------------------------------------------
-- 2. lazy.nvim 플러그인 매니저 설치
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 3. 플러그인 설정 및 로드
-----------------------------------------------------------
require("lazy").setup({
    -- [UI & 테마]
    {
        "projekt0n/github-nvim-theme",
        lazy = false,
        priority = 1000,
        config = function()
            require('github-theme').setup({
                options = { transparent = false, styles = { comments = 'italic', keywords = 'bold' } }
            })
            vim.cmd('colorscheme github_dark_dimmed')
            vim.cmd('highlight NERDTreeNormal guibg=#484f58')
            vim.cmd('highlight NERDTreeEndOfBuffer guibg=#484f58')
        end
    },
    { "vim-airline/vim-airline" },
    { "wellle/context.vim" },

    -- [탐색 및 검색]
    { "junegunn/fzf", build = "./install --all" },
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        config = function()
            vim.g.fzf_action = {
                ['ctrl-t'] = 'tab split',
                ['ctrl-x'] = 'split',
                ['ctrl-v'] = 'vsplit'
            }
        end
    },
    { "preservim/nerdtree" },
    
    -- [편집 도구]
    { "airblade/vim-gitgutter" },
    { "easymotion/vim-easymotion" },
    { "sheerun/vim-polyglot" },
    { "tpope/vim-fugitive" },

    -- [터미널 토글 (ToggleTerm)]
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-\>]],
                direction = 'horizontal',
                shade_terminals = true,
                start_in_insert = true,
                persist_size = true,
                close_on_exit = true,
            })
            
            function _G.set_terminal_keymaps()
                -- fzf 창에서는 ESC가 창을 닫도록 예외 처리
                if vim.fn.bufname():find("fzf") then
                    return
                end
                local opts = {buffer = 0}
                vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
                vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
                vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            end
            vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
        end
    },

    -- [LSP & 자동완성]
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"
        }
    }
})

-----------------------------------------------------------
-- 4. 기본 옵션 (임베디드 개발 최적화)
-----------------------------------------------------------
opt.termguicolors = true
opt.encoding = "utf-8"
opt.number = true
opt.hlsearch = true
opt.autoindent = true
opt.cindent = true
opt.smartindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = false
opt.scrolloff = 2
opt.wildmode = "longest,list"
opt.autowrite = true
opt.autoread = true
opt.backspace = "eol,start,indent"
opt.history = 256
opt.laststatus = 2
opt.showmatch = true
opt.smartcase = true
opt.incsearch = true
opt.ruler = true
opt.updatetime = 0
opt.statusline = " %<%l:%v [%P]%=%a %h%m%r %F "

if vim.env.LANG and (string.sub(vim.env.LANG, 1, 2) == "ko") then
    opt.fileencoding = "korea"
end

-----------------------------------------------------------
-- 5. 창(Window) 관리 (사이드바 보호)
-----------------------------------------------------------
local function is_sidebar(win_id)
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
    return ft == "nerdtree" or ft == "qf" or ft == "toggleterm"
end

local function move_window_left()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd h')
    local target_win = vim.api.nvim_get_current_win()
    if target_win ~= cur_win then
        if is_sidebar(target_win) then
            vim.api.nvim_set_current_win(cur_win)
        else
            vim.cmd('wincmd x')
        end
    end
end

local function move_window_right()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd l')
    local target_win = vim.api.nvim_get_current_win()
    if target_win ~= cur_win then
        if is_sidebar(target_win) then
            vim.api.nvim_set_current_win(cur_win)
        else
            vim.api.nvim_set_current_win(cur_win)
            vim.cmd('wincmd x')
            vim.cmd('wincmd l')
        end
    end
end

local map = vim.keymap.set
map('n', '<C-w>H', move_window_left, { desc = "Move window left" })
map('n', '<C-w>L', move_window_right, { desc = "Move window right" })
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-----------------------------------------------------------
-- 6. fzf 실행 시 NERDTree 보호 로직
-----------------------------------------------------------
local function find_files_smart()
    if vim.bo.filetype == 'nerdtree' then
        vim.cmd('wincmd p')
    end
    vim.cmd('Files')
end

map('n', '<leader>f', find_files_smart, { silent = true, desc = "Find Files (Smart)" })

map('n', '`', ':NERDTreeToggle<CR>', { silent = true })
map('n', '<leader>Q', ':qa!<CR>', { desc = "Force Quit All" })
map({'n', 'v'}, 'y', '"+y')
map('n', '<C-w>]', ':vsp<CR><C-w>l:execute "tag " . expand("<cword>")<CR>')

-----------------------------------------------------------
-- 7. Zoom Toggle (NERDTree & Terminal 크기 고정)
-----------------------------------------------------------
local function restore_fixed_windows()
    local cur_win = vim.api.nvim_get_current_win() -- 현재 내가 있는 창 번호
    local wins = vim.api.nvim_tabpage_list_wins(0)
    
    for _, win in ipairs(wins) do
        -- ★ 핵심: 현재 내가 보고 있는 창(Focus)은 크기 고정 대상에서 제외!
        if win ~= cur_win then
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            
            -- 다른 곳에 있는 NERDTree는 31칸으로 고정
            if ft == 'nerdtree' then
                vim.api.nvim_win_set_width(win, 31)
            -- 다른 곳에 있는 터미널은 15줄로 고정
            elseif ft == 'toggleterm' then
                vim.api.nvim_win_set_height(win, 15)
            end
        end
    end
end

map('n', '<leader>z', function()
    if vim.t.zoomed then
        -- [복구 모드] 모든 창을 원래 크기로
        vim.cmd('wincmd =')
        -- 복구할 때는 모든 특수 창을 다시 고정 크기로 꾹 누름
        local wins = vim.api.nvim_tabpage_list_wins(0)
        for _, win in ipairs(wins) do
            local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
            if ft == 'nerdtree' then vim.api.nvim_win_set_width(win, 31)
            elseif ft == 'toggleterm' then vim.api.nvim_win_set_height(win, 15) end
        end
        vim.t.zoomed = false
        print("Windows Restored")
    else
        -- [확대 모드] 현재 창을 최대화
        vim.cmd('wincmd _')
        vim.cmd('wincmd |')
        -- 현재 창을 제외한 나머지 사이드바들만 크기 고정
        restore_fixed_windows()
        vim.t.zoomed = true
        print("Window Maximized")
    end
end, { desc = "Toggle Zoom (Smart Sidebar Protection)" })

-----------------------------------------------------------
-- 8. 기타 단축키
-----------------------------------------------------------
map('n', '<F1>', ':tabprevious<CR>')
map('n', '<F2>', ':tabnew<CR>')
map('n', '<F3>', ':tabnext<CR>')
map('n', 'gl', vim.diagnostic.open_float, { desc = "Show diagnostic" })
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

if vim.fn.has("cscope") == 1 then
    opt.cscopetag = true
    opt.cscopeverbose = true
    if vim.fn.filereadable("cscope.out") == 1 then vim.cmd("silent! cs add cscope.out") end
end

vim.api.nvim_create_user_command('B', 'Buffers', {})
vim.api.nvim_create_user_command('L', 'Lines', {})
vim.api.nvim_create_user_command('R', 'Rg', {})

-----------------------------------------------------------
-- 9. LSP & 자동완성
-----------------------------------------------------------
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason-lspconfig").setup({
    ensure_installed = { "clangd" },
    handlers = {
        function(server_name)
            local opts = { capabilities = capabilities }
            if server_name == "clangd" then
                opts.cmd = { "clangd", "--query-driver=/**/*gcc,/**/*g++" }
            end
            lspconfig[server_name].setup(opts)
        end,
    }
})

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'luasnip' } }, { { name = 'buffer' }, { name = 'path' } })
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
})
