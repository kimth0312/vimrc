-----------------------------------------------------------
-- 1. 전역 설정 (Leader Key & 전역 옵션)
-----------------------------------------------------------
vim.g.mapleader = " "
local opt = vim.opt

-----------------------------------------------------------
-- 2. lazy.nvim 설치
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 3. 플러그인 설정 (fzf-lua 및 nvim 전용 플러그인)
-----------------------------------------------------------
require("lazy").setup({
    -- [UI & Icons]
    { "nvim-tree/nvim-web-devicons", lazy = false },
    {
        "projekt0n/github-nvim-theme",
        lazy = false,
        priority = 1000,
        config = function()
            require('github-theme').setup({
                options = { transparent = false, styles = { comments = 'italic', keywords = 'bold' } }
            })
            vim.cmd('colorscheme github_dark_dimmed')
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = { options = { theme = 'auto', section_separators = '', component_separators = '' } }
    },

    -- [탐색 및 검색 (fzf-lua)]
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require('fzf-lua').setup({
                "fzf-vim",
                keymap = { fzf = { ["ctrl-j"] = "down", ["ctrl-k"] = "up" } }
            })
        end
    },

    -- [파일 트리 (nvim-tree)]
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local function my_on_attach(bufnr)
                local api = require('nvim-tree.api')
                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                api.config.mappings.default_on_attach(bufnr)
                -- 's' 키를 눌렀을 때 VS Code 대신 nvim 내부에서 세로 분할로 열기
                vim.keymap.set('n', 's', api.node.open.vertical, opts('Vertical Split'))
                vim.keymap.set('n', 'i', api.node.open.horizontal, opts('Horizontal Split'))
            end

            require("nvim-tree").setup({
                on_attach = my_on_attach,
                sync_root_with_cwd = true,
                update_focused_file = { enable = true, update_root = true },
                view = { width = 31, side = "left" },
            })
        end
    },

    -- [편집 및 문법 (Treesitter)]
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "c", "cpp", "rust", "lua", "bash", "make" },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
        },
        config = function(_, opts)
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if ok then configs.setup(opts) end
        end
    },
    { "lewis6991/gitsigns.nvim", config = true },
    { "nvim-treesitter/nvim-treesitter-context", config = true },
    { "phaazon/hop.nvim", branch = 'v2', config = true },

    -- [LSP & 자동완성]
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
	{
        "karb94/neoscroll.nvim",
        config = function()
            require('neoscroll').setup({
                -- 이 부분에 아래의 설정값들을 넣을 수 있습니다.
                mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
                             '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
                hide_cursor = false,          -- 스크롤 중 커서 숨김
                stop_eof = true,             -- 파일 끝에서 중지
                respect_scrolloff = false,   -- scrolloff 옵션 무시 여부
                cursor_scroll_step = 1,      -- 커서 스크롤 단계
                easing_function = "quadratic" -- 애니메이션 효과 (quadratic, cubic, quartic 등)
            })
        end
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"
        }
    }
})

-----------------------------------------------------------
-- 4. 기본 옵션 (임베디드 개발 최적화)
-----------------------------------------------------------
opt.termguicolors = true
opt.number = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false -- 커널 코딩 스타일(Tab) 준수
opt.smartindent = true
opt.updatetime = 250
opt.scrolloff = 2
opt.mouse = "a"

if vim.env.LANG and (string.sub(vim.env.LANG, 1, 2) == "ko") then
    opt.fileencoding = "korea"
end

-----------------------------------------------------------
-- 5. 창 관리 및 사이드바 보호 로직
-----------------------------------------------------------
local function is_sidebar(win_id)
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
    return ft == "NvimTree" or ft == "qf"
end

local function move_window_left()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd h')
    local target_win = vim.api.nvim_get_current_win()
    if target_win ~= cur_win and is_sidebar(target_win) then
        vim.api.nvim_set_current_win(cur_win)
    elseif target_win ~= cur_win then
        vim.cmd('wincmd x')
    end
end

local function move_window_right()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd l')
    local target_win = vim.api.nvim_get_current_win()
    if target_win ~= cur_win and is_sidebar(target_win) then
        vim.api.nvim_set_current_win(cur_win)
    end
end

local map = vim.keymap.set
map('n', '<C-w>H', move_window_left)
map('n', '<C-w>L', move_window_right)
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-----------------------------------------------------------
-- 6. 단축키 및 명령어 (fzf-lua & Zoom & Tag)
-----------------------------------------------------------
local function get_fzf() return require('fzf-lua') end

-- :B, :R, :L 명령어
vim.api.nvim_create_user_command('B', function() get_fzf().buffers() end, {})
vim.api.nvim_create_user_command('R', function() get_fzf().live_grep() end, {})
vim.api.nvim_create_user_command('L', function() get_fzf().blines() end, {})

map('n', '<leader>f', function()
    if vim.bo.filetype == 'NvimTree' then vim.cmd('wincmd p') end
    get_fzf().files()
end)

-- [수정 2] Ctrl+w+] 를 세로 분할 태그 점프로 변경
map('n', '<C-w>]', ':vsp<CR><C-w>l:execute "tag " . expand("<cword>")<CR>', { desc = "Vertical split tag jump" })

-- [수정 3] Zoom Toggle 시 NvimTree 고정 로직
map('n', '<leader>z', function()
    if vim.t.zoomed then
        vim.cmd('wincmd =')
        -- 복구 시 NvimTree 너비 재설정
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
                vim.api.nvim_win_set_width(win, 31)
            end
        end
        vim.t.zoomed = false
    else
        vim.cmd('wincmd _')
        vim.cmd('wincmd |')
        -- 최대화 후에도 NvimTree 너비 고정 (핵심 해결책)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
                vim.api.nvim_win_set_width(win, 31)
            end
        end
        vim.t.zoomed = true
    end
end, { desc = "Toggle Zoom with fixed Tree" })

map('n', '<F1>', ':tabprevious<CR>')
map('n', '<F2>', ':tabnew<CR>')
map('n', '<F3>', ':tabnext<CR>')
map('n', '<leader>,', ':-tabmove<CR>')
map('n', '<leader>.', ':+tabmove<CR>')
map('n', '`', ':NvimTreeToggle<CR>', { silent = true })

-----------------------------------------------------------
-- 7. LSP & 자동완성 설정
-----------------------------------------------------------
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "rust_analyzer" },
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
cmp.setup({
    snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            else fallback() end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = 'buffer' }, { name = 'path' } })
})

-----------------------------------------------------------
-- 8. Floating Terminal (투명도 복원)
-----------------------------------------------------------
local float_term = { buf = nil, win = nil }
function ToggleFloatingTerminal()
    if float_term.win and vim.api.nvim_win_is_valid(float_term.win) then
        vim.api.nvim_win_hide(float_term.win)
        float_term.win = nil
        return
    end
    if not float_term.buf or not vim.api.nvim_buf_is_valid(float_term.buf) then
        float_term.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_call(float_term.buf, function() vim.fn.termopen(vim.o.shell) end)
    end
    local w, h = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
    float_term.win = vim.api.nvim_open_win(float_term.buf, true, {
        relative = "editor", width = w, height = h,
        col = (vim.o.columns - w) / 2, row = (vim.o.lines - h) / 2,
        style = "minimal", border = "rounded",
    })

    -- [수정 1] 투명도(winblend) 설정 복원
    vim.api.nvim_set_option_value("winblend", 20, { scope = "local", win = float_term.win })

    vim.cmd("startinsert")
end
map({ "n", "t" }, [[<C-\>]], ToggleFloatingTerminal)
