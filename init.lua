-- ~/.config/nvim/init.lua

-----------------------------------------------------------
-- 1. 전역 설정 및 리더키 (Leader Key)
-----------------------------------------------------------
vim.g.mapleader = " "
local opt = vim.opt

-----------------------------------------------------------
-- 2. lazy.nvim 플러그인 매니저 설치 (Bootstrap)
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 3. 플러그인 설정 및 로드 (lazy.nvim)
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
            -- NERDTree 배경색 커스텀 (밝게)
            vim.cmd('highlight NERDTreeNormal guibg=#484f58')
            vim.cmd('highlight NERDTreeEndOfBuffer guibg=#484f58')
        end
    },
    { "vim-airline/vim-airline" },
    { "wellle/context.vim" },

    -- [탐색 및 검색]
    { "junegunn/fzf", build = "./install --all" },
    { "junegunn/fzf.vim" },
    { "preservim/nerdtree" },
    
    -- [편집 도구]
    { "airblade/vim-gitgutter" },
    { "easymotion/vim-easymotion" },
    { "sheerun/vim-polyglot" },
    { "tpope/vim-fugitive" },

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
-- 4. .vimrc 기본 옵션 통합 (임베디드 개발 최적화)
-----------------------------------------------------------
opt.termguicolors = true
opt.encoding = "utf-8"
opt.number = true           -- 줄 번호 (nu)
opt.hlsearch = true         -- 검색 하이라이트
opt.autoindent = true       -- 자동 들여쓰기
opt.cindent = true          -- C 스타일 들여쓰기
opt.smartindent = true
opt.tabstop = 8             -- 탭 너비 4 (커널 개발 시 8로 변경 가능)
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = false       -- 탭 문자 그대로 사용 (Linux Kernel 스타일)
opt.scrolloff = 2
opt.wildmode = "longest,list"
opt.autowrite = true        -- 자동 저장
opt.autoread = true         -- 외부 변경 시 자동 로드
opt.backspace = "eol,start,indent"
opt.history = 256
opt.laststatus = 2
opt.showmatch = true        -- 일치하는 괄호 강조
opt.smartcase = true        -- 대소문자 스마트 검색
opt.incsearch = true
opt.ruler = true            -- 커서 위치 표시
opt.updatetime = 0
opt.statusline = " %<%l:%v [%P]%=%a %h%m%r %F "

-- 한국어 인코딩 처리
if vim.env.LANG and (string.sub(vim.env.LANG, 1, 2) == "ko") then
    opt.fileencoding = "korea"
end

-----------------------------------------------------------
-- 5. 창(Window) 관리 및 이동 (개선된 로직)
-----------------------------------------------------------
-- 사이드바 여부 체크 함수
local function is_sidebar(win_id)
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
    return ft == "nerdtree" or ft == "qf"
end

-- [한 칸씩 이동] 왼쪽으로 옮기기 (사이드바 보호)
local function move_window_left()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd h') -- 일단 왼쪽으로 가봄
    local target_win = vim.api.nvim_get_current_win()

    if target_win ~= cur_win then
        if is_sidebar(target_win) then
            vim.api.nvim_set_current_win(cur_win) -- 사이드바면 다시 돌아옴
            print("NERDTree 위치는 왼쪽으로 고정되어 있습니다.")
        else
            vim.cmd('wincmd x') -- 일반 창이면 위치 교체
        end
    end
end

-- [한 칸씩 이동] 오른쪽으로 옮기기 (사이드바 보호)
local function move_window_right()
    local cur_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd l') -- 일단 오른쪽으로 가봄
    local target_win = vim.api.nvim_get_current_win()

    if target_win ~= cur_win then
        if is_sidebar(target_win) then
            vim.api.nvim_set_current_win(cur_win)
            print("사이드바와 자리를 바꿀 수 없습니다.")
        else
            vim.api.nvim_set_current_win(cur_win) -- 원래 창에서
            vim.cmd('wincmd x') -- 교체 후
            vim.cmd('wincmd l') -- 커서 따라가기
        end
    end
end

local map = vim.keymap.set
map('n', '<C-w>H', move_window_left, { desc = "Move window left" })
map('n', '<C-w>L', move_window_right, { desc = "Move window right" })
map('n', '<leader>=', '<C-w>=', { desc = "Equalize windows" })

-- 단순 커서 이동 (Ctrl+h,j,k,l)
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-----------------------------------------------------------
-- 6. NERDTree 자동 동기화 (fzf 파일 탐색 시 필수)
-----------------------------------------------------------
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("NERDTreeSync", { clear = true }),
    callback = function()
        if vim.bo.buftype ~= "" or vim.bo.filetype == "nerdtree" or vim.fn.expand("%") == "" then
            return
        end
        local is_open = false
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "nerdtree" then
                is_open = true
                break
            end
        end
        if is_open then
            vim.cmd("silent! NERDTreeFind")
            vim.cmd("wincmd p")
        end
    end,
})

-----------------------------------------------------------
-- 7. 기타 단축키 및 사용자 명령어 (.vimrc 통합)
-----------------------------------------------------------
-- 탭 관리
map('n', '<F1>', ':tabprevious<CR>')
map('n', '<F2>', ':tabnew<CR>')
map('n', '<F3>', ':tabnext<CR>')

-- fzf & NERDTree
map('n', '<leader>f', ':Files<CR>', { silent = true })
map('n', '`', ':NERDTreeToggle<CR>', { silent = true })

-- EasyMotion
map('n', '<leader><leader>j', '<Plug>(easymotion-w)')
map('n', '<leader><leader>k', '<Plug>(easymotion-b)')

-- 시스템 클립보드 복사
map({'n', 'v'}, 'y', '"+y')

-- 태그 점프 (세로 분할 후 점프)
map('n', '<C-w>]', ':vsp<CR><C-w>l:execute "tag " . expand("<cword>")<CR>')

-- fzf 커스텀 명령어
vim.api.nvim_create_user_command('B', 'Buffers', {})
vim.api.nvim_create_user_command('L', 'Lines', {})
vim.api.nvim_create_user_command('R', 'Rg', {})

-- 마지막 수정 위치 기억
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Cscope 설정
if vim.fn.has("cscope") == 1 then
    opt.cscopetag = true
    opt.cscopeverbose = true
    if vim.fn.filereadable("cscope.out") == 1 then
        vim.cmd("silent! cs add cscope.out")
    end
end

-----------------------------------------------------------
-- 8. LSP & 자동완성 상세 설정
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
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }, { name = 'luasnip' }
    }, {
        { name = 'buffer' }, { name = 'path' }
    })
})
