-- ~/.config/nvim/init.lua
vim.cmd('source ~/.vimrc')

-- [중요] 테마 색상 깨짐 방지를 위한 True Color 설정 (테마 적용 전 필수)
vim.opt.termguicolors = true

-----------------------------------------------------------
-- 1. Vim-Plug 설정
-----------------------------------------------------------
vim.cmd [[
    call plug#begin('~/.local/share/nvim/plugged')

    " LSP & Autocompletion
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'

    " Completion
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'

    " [추가됨] Github Theme
    Plug 'projekt0n/github-nvim-theme'

    call plug#end()
]]

-----------------------------------------------------------
-- 2. 테마 설정 (플러그인 로드 후 실행)
-----------------------------------------------------------
-- 테마 상세 설정
require('github-theme').setup({
    options = {
        transparent = false, -- 배경 투명화 (tmux 사용 시 true 추천)
        styles = {
            comments = 'italic',
            keywords = 'bold',
        }
    }
})

-- 테마 적용 (원하는 스타일로 변경 가능: github_dark_dimmed, github_light 등)
vim.cmd('colorscheme github_dark_dimmed')

-----------------------------------------------------------
-- [수정] NERDTree 배경색 강제 변경 (밝게 하기)
-----------------------------------------------------------
-- #21262d : Github UI에서 사용하는 옅은 회색입니다.
-- 더 밝게 하고 싶으면 #30363d 또는 #484f58 로 숫자를 바꿔보세요.
vim.cmd([[
    highlight NERDTreeNormal guibg=#484f58
    highlight NERDTreeEndOfBuffer guibg=#484f58
]])


-----------------------------------------------------------
-- 3. 기타 설정 (LSP, CMP 등)
-----------------------------------------------------------

-- (1) Mason (서버 설치 관리자) 설정
require("mason").setup()

-- (2) Mason-LSPConfig + LSP 설정
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason-lspconfig").setup({
    ensure_installed = { "clangd" },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({
                capabilities = capabilities,
            })
        end,
    }
})

-- (3) nvim-cmp 자동완성 설정
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
}) -- 괄호 닫기 수정됨
