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

			vim.cmd([[
                highlight TreesitterContext guibg=NONE
                highlight TreesitterContextBottom gui=underline guisp=#484f58
                highlight TreesitterContextLineNumber guibg=NONE guifg=#484f58
            ]])
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
            highlight = { enable = true, additional_vim_regex_highlighting = {"c", "cpp"}, }
        },
        config = function(_, opts)
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if ok then configs.setup(opts) end
        end
    },
    { "lewis6991/gitsigns.nvim", config = true },
    { "nvim-treesitter/nvim-treesitter-context", 
	  config = function()
		require('treesitter-context').setup({
                enable = true,
                max_lines = 5,           -- 너무 길어지지 않게 최대 5줄만 표시
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20, -- 인자가 많아 줄바꿈된 함수도 잘 잡도록 설정
                trim_scope = 'outer',    -- 긴 함수에서 바깥쪽 스코프부터 표시
                mode = 'topline',         -- 커서 위치 기준으로 정확하게 계산
            })
        end
	  },

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
                stop_eof = false,             -- 파일 끝에서 중지
                respect_scrolloff = false,   -- scrolloff 옵션 무시 여부
                cursor_scroll_step = 1,      -- 커서 스크롤 단계
                easing_function = "quadratic" -- 애니메이션 효과 (quadratic, cubic, quartic 등)
            })
        end
    },
	-- [빠른 이동 (Hop)] - space+space 기능을 담당
	{
        "smoka7/hop.nvim",
        version = "*",
        config = function()
            require('hop').setup({ keys = 'etovxqpdygfblzhckisuran' })
        end
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"
        }
    },
	{
		"numToStr/Comment.nvim",
		config = function()
			require('Comment').setup()
			vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
			vim.keymap.set('v', '<C-/>', 'gc', { remap = true })
		end
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

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.cmd([[
            syntax keyword Keyword __init __exit __meminit __always_inline __user __kernel
            syntax keyword Keyword asmlinkage SYSCALL_DEFINE[0-6]
        ]])
    end,
})

-- Diagnostic(에러 표시) 설정
vim.diagnostic.config({
    virtual_text = false, -- 코드 옆에 뜨는 거슬리는 텍스트 끔
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

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
    if target_win ~= cur_win then
        if is_sidebar(target_win) then
            vim.api.nvim_set_current_win(cur_win)
        else
            -- 현재 창과 타겟 창의 위치를 교체
            vim.api.nvim_set_current_win(cur_win)
            vim.cmd('wincmd x')
            vim.cmd('wincmd l')
        end
    end
end

local map = vim.keymap.set
map('n', '<C-w>H', move_window_left)
map('n', '<C-w>L', move_window_right)
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

map('n', 'gl', vim.diagnostic.open_float, { desc = "Show diagnostic error" })

-----------------------------------------------------------
-- 6. 단축키 및 명령어 (fzf-lua & Zoom & Tag)
-----------------------------------------------------------
local function get_fzf() return require('fzf-lua') end

map('n', '<leader>b', function() require('fzf-lua').buffers() end, { desc = "FZF Buffers" })

map('n', '<leader>f', function()
    if vim.bo.filetype == 'NvimTree' then vim.cmd('wincmd p') end
    get_fzf().files()
end)

-- [Hop 방향성 단어 점프 설정]
local hop = require('hop')
local hint_expect = require('hop.hint').HintDirection

-- Space + Space + j : 아래 방향 단어들로 점프
map('n', '<leader><leader>j', function() 
    hop.hint_words({ direction = hint_expect.AFTER_CURSOR }) 
end, { desc = "Hop to words below" })

-- Space + Space + k : 위 방향 단어들로 점프
map('n', '<leader><leader>k', function() 
    hop.hint_words({ direction = hint_expect.BEFORE_CURSOR }) 
end, { desc = "Hop to words above" })

-- ★ [핵심 추가] 검색(n, N) 시 부드러운 스크롤 적용
-- n: 다음 찾기, N: 이전 찾기 후 화면 중앙(zz)으로 부드럽게 이동
map('n', 'n', [[n<Cmd>lua require('neoscroll').zz({ half_win_duration = 250, move_cursor = true })<CR>]])
map('n', 'N', [[N<Cmd>lua require('neoscroll').zz({ half_win_duration = 250, move_cursor = true })<CR>]])

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

-- ESC 키를 누르면 검색 하이라이트 해제
map('n', '<Esc>', '<cmd>noh<CR>', { desc = "Clear search highlights" })

map('n', 'gr', "<cmd>lua require('fzf-lua').grep_cword()<cr>", { 
    noremap = true, 
    silent = true, 
    desc = "FZF Search Word Under Cursor" 
})

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
                -- ⭐ 핵심 2: clangd가 문맥을 분석해 하이라이트를 직접 주도록 설정
                opts.on_attach = function(client, bufnr)
                    client.server_capabilities.semanticTokensProvider = {
                        full = true,
                        legend = { tokenTypes = { "function", "variable", "parameter" }, tokenModifiers = {} }
                    }
                end
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

-----------------------------------------------------------
-- nvim-tree의 현재 루트 디렉토리를 가져오는 함수
-----------------------------------------------------------
local function get_root()
    -- nvim-tree의 내부 코어를 통해 현재 트리가 열고 있는 최상위 경로를 가져옵니다.
    local ok, core = pcall(require, "nvim-tree.core")
    if ok and core.get_explorer() then
        local tree_root = core.get_explorer().absolute_path
        if tree_root then
            return tree_root
        end
    end

    -- nvim-tree가 열려있지 않거나 경로를 못 가져올 경우 현재 작업 디렉토리 반환
    return vim.fn.getcwd()
end

function ToggleFloatingTerminal()
    -- 1. 현재 탭에 열려있는 터미널 창이 있는지 확인
    local terminal_win = vim.t.terminal_win
    if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
        vim.api.nvim_win_hide(terminal_win)
        vim.t.terminal_win = nil
        return
    end

    -- 2. 현재 파일의 프로젝트 루트 확인 (기존 get_root 함수 활용)
    local root_path = get_root()

    -- 3. 현재 탭 전용 터미널 버퍼가 있는지 확인
    local terminal_buf = vim.t.terminal_buf
    if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
        -- 새 버퍼 생성 및 탭 로컬 변수에 저장
        terminal_buf = vim.api.nvim_create_buf(false, true)
        vim.t.terminal_buf = terminal_buf
        
        -- 해당 버퍼에서 현재 프로젝트 루트를 기반으로 새 셸 실행
        vim.api.nvim_buf_call(terminal_buf, function()
            vim.fn.termopen(vim.o.shell, { cwd = root_path })
        end)
    end

    -- 4. 플로팅 윈도우 설정
    local w, h = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
    local new_win = vim.api.nvim_open_win(terminal_buf, true, {
        relative = "editor",
        width = w,
        height = h,
        col = (vim.o.columns - w) / 2,
        row = (vim.o.lines - h) / 2,
        style = "minimal",
        border = "rounded",
    })

    -- 5. 윈도우 핸들 저장 및 투명도 설정
    vim.t.terminal_win = new_win
    vim.api.nvim_set_option_value("winblend", 20, { scope = "local", win = new_win })
    
    vim.cmd("startinsert")
end

map({ "n", "t" }, [[<C-\>]], ToggleFloatingTerminal)


-----------------------------------------------------------
-- 9. Utility
-----------------------------------------------------------

