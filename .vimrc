set nocompatible
set encoding=utf-8

call plug#begin('~/.vim/plugged')

" 플러그인 목록
Plug 'wellle/context.vim'        " 코드 컨텍스트 표시
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " fuzzy finder
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'         " 파일 트리
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'

call plug#end()

set updatetime=0

" F1: 새 탭 생성
nnoremap <F2> :tabnew<CR>

" F2: 이전 탭으로 이동
nnoremap <F1> :tabprevious<CR>

" F3: 다음 탭으로 이동
nnoremap <F3> :tabnext<CR>

let mapleader = "\<Space>"
" <Space>f : 파일 검색
nnoremap <silent> <leader>f :Files<CR>

" NERDTree를 백틱(`) 키로 토글
nnoremap <silent> ` :NERDTreeToggle<CR>

nmap <leader><leader>j <Plug>(easymotion-w)
nmap <leader><leader>k <Plug>(easymotion-b)

nmap <c-h> <c-w>h
nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-l> <c-w>l

command! B Buffers
command! L Lines
command! R Rg

set hlsearch " 검색어 하이라이팅
set nu " 줄번호
set autoindent " 자동 들여쓰기
set scrolloff=2
set wildmode=longest,list
set ts=4 "tag select
set sts=4 "st select
set sw=1 " 스크롤바 너비
set autowrite " 다른 파일로 넘어갈 때 자동 저장
set autoread " 작업 중인 파일 외부에서 변경됬을 경우 자동으로 불러옴
set cindent " C언어 자동 들여쓰기
set bs=eol,start,indent
set history=256
set laststatus=2 " 상태바 표시 항상
"set paste " 붙여넣기 계단현상 없애기
set shiftwidth=4 " 자동 들여쓰기 너비 설정
set showmatch " 일치하는 괄호 하이라이팅
set smartcase " 검색시 대소문자 구별
set smarttab
set smartindent
set softtabstop=4
set tabstop=4
set ruler " 현재 커서 위치 표시
set incsearch
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\
" 마지막으로 수정된 곳에 커서를 위치함
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif
" 파일 인코딩을 한국어로
if $LANG[0]=='k' && $LANG[1]=='o'
set fileencoding=korea
endif
" 구문 강조 사용
syntax on
" 컬러 스킴 사용
filetype plugin indent on

if has("cscope")
    set cscopetag
    set cscopeverbose
    if filereadable("cscope.out")
        silent! cs add cscope.out
    endif
endif

nnoremap y "+y
vnoremap y "+y

nnoremap <C-w>] :vsp<CR><C-w>l:execute "tag " . expand("<cword>")<CR>
