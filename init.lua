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
-- 3. 플러그인 설정
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
            vim.keymap.set('n', 's', api.node.open.vertical, opts('Vertical Split'))
            vim.keymap.set('n', 'i', api.node.open.horizontal, opts('Horizontal Split'))
        end

        require("nvim-tree").setup({
            on_attach = my_on_attach,
            sync_root_with_cwd = true,
            update_focused_file = { enable = true, update_root = true },
            view = { width = 31, side = "left" },
            
            -- ★ 파일이 안 보일 때 수정해야 할 핵심 설정
            filters = {
                dotfiles = false,      -- 점(.)으로 시작하는 파일도 모두 표시
                custom = { "^.git$" }, -- .git 폴더 자체만 숨기고 나머지는 다 표시
            },
            git = {
                enable = true,
                ignore = false,        -- ★ 중요: .gitignore에 등록된 파일도 트리에 표시
                timeout = 500,
            },
            renderer = {
                highlight_git = true,  -- git 상태(ignored 등)를 색상으로 구분해줌
            }
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
    { 
        "nvim-treesitter/nvim-treesitter-context",  
        config = function()
            require('treesitter-context').setup({
                enable = true,
                max_lines = 5,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = 'outer',
                mode = 'topline',
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
                mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
                hide_cursor = false,
                stop_eof = false,
                respect_scrolloff = false,
                cursor_scroll_step = 1,
                easing_function = "quadratic"
            })
        end
    },
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
            -- 리눅스 터미널 호환성을 위해 <C-/>와 <C-_> 모두 매핑
            vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
            vim.keymap.set('v', '<C-/>', 'gc', { remap = true })
            vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
            vim.keymap.set('v', '<C-_>', 'gc', { remap = true })
        end
    },
	{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true, -- treesitter 기반으로 더 정확하게
        })
    end
	}
})

-----------------------------------------------------------
-- 4. 기본 옵션 (Ubuntu & 임베디드 최적화)
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

-- ★ Ubuntu 필수: 시스템 클립보드 연동 (xclip 또는 wl-clipboard 설치 필요)
opt.clipboard = "unnamedplus"

-- ★ 인코딩 설정: UTF-8 우선, 필요 시 한글 지원
opt.fileencodings = "utf-8,korea,cp949"
opt.encoding = "utf-8"

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

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

opt.guicursor = "n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20"

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
-- 6. 단축키 및 명령어
-----------------------------------------------------------
local function get_fzf() return require('fzf-lua') end

local hop = require('hop')
local hint_expect = require('hop.hint').HintDirection

map('n', '<leader><leader>j', function() 
    hop.hint_words({ direction = hint_expect.AFTER_CURSOR }) 
end, { desc = "Hop down" })

map('n', '<leader><leader>k', function() 
    hop.hint_words({ direction = hint_expect.BEFORE_CURSOR }) 
end, { desc = "Hop up" })

-- 검색 시 부드러운 스크롤
map('n', 'n', [[n<Cmd>lua require('neoscroll').zz({ half_win_duration = 250, move_cursor = true })<CR>]])
map('n', 'N', [[N<Cmd>lua require('neoscroll').zz({ half_win_duration = 250, move_cursor = true })<CR>]])

map('n', '<C-w>]', ':vsp<CR><C-w>l:execute "tag " . expand("<cword>")<CR>', { desc = "Vertical split tag jump" })

map('n', '<leader>z', function()
    if vim.t.zoomed then
        vim.cmd('wincmd =')
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
                vim.api.nvim_win_set_width(win, 31)
            end
        end
        vim.t.zoomed = false
    else
        vim.cmd('wincmd _')
        vim.cmd('wincmd |')
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
                vim.api.nvim_win_set_width(win, 31)
            end
        end
        vim.t.zoomed = true
    end
end, { desc = "Toggle Zoom" })

map('n', '<F1>', ':tabprevious<CR>')
map('n', '<F2>', ':tabnew<CR>')
map('n', '<F3>', ':tabnext<CR>')
map('n', '`', ':NvimTreeToggle<CR>', { silent = true })
map('n', '<Esc>', '<cmd>noh<CR>')

-- nvim-tree의 현재 Root 경로를 가져오는 함수
local function get_nvim_tree_root()
    local api = require("nvim-tree.api")
    -- 현재 트리의 상태를 가져옴
    local tree_status = api.tree.get_nodes()
    
    -- 트리가 열려 있고 root 경로가 존재한다면 해당 경로 반환
    if tree_status and tree_status.absolute_path then
        return tree_status.absolute_path
    end
    
    -- 트리가 없거나 경로를 못 가져오면 현재 탭의 CWD 반환
    return vim.fn.getcwd()
end

-- [파일 찾기] nvim-tree의 root 기준
map('n', '<leader>f', function()
    local root = get_nvim_tree_root()
    if vim.bo.filetype == 'NvimTree' then vim.cmd('wincmd p') end
    get_fzf().files({ cwd = root })
end, { desc = "FZF Files (NvimTree Root)" })

-- [문자열 검색] nvim-tree의 root 기준
map('n', '<leader>r', function() 
    local root = get_nvim_tree_root()
    get_fzf().live_grep({ cwd = root }) 
end, { desc = "FZF Live Grep (NvimTree Root)" })

-- [버퍼 검색]
map('n', '<leader>b', function() 
    get_fzf().buffers() -- 버퍼는 전역이므로 cwd 영향이 적음
end, { desc = "FZF Buffers" })

-- [현재 단어 검색] nvim-tree의 root 기준
map('n', 'gr', function()
    local root = get_nvim_tree_root()
    get_fzf().grep_cword({ cwd = root })
end, { silent = true, desc = "Grep Word (NvimTree Root)" })

-- 1. 연속 리사이즈 함수 (이전과 동일)
local function start_resize_mode(direction_cmd)
    vim.cmd(direction_cmd)
    vim.cmd("redraw")
    print("-- Resize mode --")

    while true do
        local ok, char = pcall(vim.fn.getchar)
        if not ok then break end
        local key = vim.fn.nr2char(char)

        if key == "," then
            vim.cmd("vertical resize -5")
            vim.cmd("redraw")
        elseif key == "." then
            vim.cmd("vertical resize +5")
            vim.cmd("redraw")
        else
            local n_key = vim.api.nvim_replace_termcodes(key, true, false, true)
            vim.api.nvim_feedkeys(n_key, 'm', true)
            break
        end
    end
end

-- 2. 스마트 리셋 함수: 현재 윈도우만 타겟팅
local function reset_current_window_smart()
    local cur_win = vim.api.nvim_get_current_win()
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)
    local ft = vim.bo[cur_buf].filetype

    if ft == "NvimTree" then
        -- 1) 현재 창이 NvimTree라면 정확히 31로 고정
        -- 이때 옆에 있는 코드 창들의 '상대적 비율'은 깨지지 않고 전체 너비만 조정됩니다.
        vim.api.nvim_win_set_width(cur_win, 31)
        print("-- NvimTree size restored --")
    else
        -- 2) 현재 창이 일반 코드 창일 경우
        -- '초기 상태'인 균등 분할(wincmd =)을 수행하되, 
        -- NvimTree가 있다면 걔는 31로 다시 고정해서 사이드바가 커지는걸 방지합니다.
        vim.cmd('wincmd =')
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'NvimTree' then
                vim.api.nvim_win_set_width(win, 31)
            end
        end
        print("-- Text editor size restored --")
    end
end

-- 단축키 매핑
map('n', '<leader>,', function() start_resize_mode("vertical resize -5") end, { desc = "Continuous Decrease Width" })
map('n', '<leader>.', function() start_resize_mode("vertical resize +5") end, { desc = "Continuous Increase Width" })
map('n', '<leader>=', reset_current_window_smart, { silent = true, desc = "Smart Reset Current Window" })


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
-- 8. Floating Terminal
-----------------------------------------------------------
local function get_root()
    local ok, core = pcall(require, "nvim-tree.core")
    if ok and core.get_explorer() then
        local tree_root = core.get_explorer().absolute_path
        if tree_root then return tree_root end
    end
    return vim.fn.getcwd()
end

function ToggleFloatingTerminal()
    -- 1. 창이 이미 열려있다면 닫기
    if vim.t.terminal_win and vim.api.nvim_win_is_valid(vim.t.terminal_win) then
        vim.api.nvim_win_hide(vim.t.terminal_win)
        vim.t.terminal_win = nil
        return
    end

    local root_path = get_root()
    local terminal_buf = vim.t.terminal_buf

    -- 2. 터미널 버퍼가 없거나 유효하지 않으면 새로 생성
    if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
        terminal_buf = vim.api.nvim_create_buf(false, true)
        vim.t.terminal_buf = terminal_buf
        
        -- 버퍼 생성 직후 터미널 실행
        vim.api.nvim_buf_call(terminal_buf, function()
            vim.fn.termopen(vim.o.shell, { cwd = root_path })
        end)
    end

    -- 3. 창 열기 (항상 최신 크기 반영)
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
    
    vim.t.terminal_win = new_win
    vim.api.nvim_set_option_value("winblend", 10, { scope = "local", win = new_win })

    -- 4. ★ 이 버퍼 내에서만 Esc 단축키 강제 할당 (충돌 방지용)
    -- 터미널 모드(t) -> 노멀 모드
    vim.api.nvim_buf_set_keymap(terminal_buf, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
    -- 노멀 모드(n) -> 터미널 입력 모드
    vim.api.nvim_buf_set_keymap(terminal_buf, 'n', '<Esc>', 'i', { noremap = true, silent = true })
    -- 터미널 모드에서 토글 키(C-\)가 먹히도록 추가
    vim.api.nvim_buf_set_keymap(terminal_buf, 't', [[<C-\>]], [[<C-\><C-n><cmd>lua ToggleFloatingTerminal()<CR>]], { noremap = true, silent = true })

    -- 5. 열자마자 바로 입력 모드로 진입
    vim.cmd("startinsert")
end

-- 전역 매핑 (Normal 모드에서 터미널 열기)
vim.keymap.set('n', [[<C-\>]], ToggleFloatingTerminal, { silent = true })
