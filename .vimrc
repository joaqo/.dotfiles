"  ========================= VIM-PLUG =============================
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/jeetsukumaran/vim-indentwise.git'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'https://github.com/w0rp/ale.git'
set statusline +=\ %{ALEGetStatusLine()}\ \
let g:ale_statusline_format = ['☀️️ %d', '🕯️ %d', '']
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
" let g:ale_sign_error = '❌'
" let g:ale_sign_warning = '⭕'

Plug 'https://github.com/JamshedVesuna/vim-markdown-preview.git'
let vim_markdown_preview_github=1
let vim_markdown_preview_toggle=1
let vim_markdown_preview_hotkey='<C-m>'
let vim_markdown_preview_temp_file=1  " <- This may cause crashing on slow browsers

call plug#end()

" Run google/yapf (not really a plugin but whatever)
autocmd FileType python nnoremap <LocalLeader>= :0,$!yapf<CR>

" Ale options
let g:ale_lint_on_save = 0
let g:ale_lint_on_text_changed = 1
let g:ale_sign_column_always = 1

" =================================================================

colorscheme molokai

runtime! debian.vim
set splitbelow "donde aparecen los nuevos splits
set splitright "donde aparecen los nuevos splits

"filetype indent plugin on

" Enable folding
set foldmethod=indent
set foldlevel=99

" Modify statusline
set statusline +=%f\  " relative path
set statusline +=%m\  " modified flag
set statusline +=%=%c\  " line length, right aligned



" Add recursive folders to path (**)
set path=.,/usr/include,,**

" Enable mouse
set mouse=a
if !has('nvim')
    set ttymouse=xterm2
endif

syntax on

au FileType python setlocal
    \ tabstop=8
    \ softtabstop=4
    \ shiftwidth=4
    \ expandtab
    \ autoindent
    \ fileformat=unix

au BufNewFile,BufRead *.py
    \ match ErrorMsg '\%>100v.\+'

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |

"set textwidth=100
"set wildmenu
set showmatch
set number
set relativenumber
set incsearch
set tabpagemax=400
set ignorecase
map Y y$
set ruler

"" Dont store swap files
set noswapfile

" " For ALE linter plugin
" highlight clear ALEErrorSign
" highlight clear ALEWarningSign
highlight clear SignColumn

" Show filename, always
set ls=2

set lazyredraw  " Don't redraw while executing macros (good performance config)
set ttyfast     " should make scrolling faster

" Remap common typos
command WQ wq
command W w
command Wq wq
command Q q
command Wa wa

" Remap vertical find to more logical command: vsf = vert sf
cnoreabbrev <expr> vsf getcmdtype() == ":" && getcmdline() == 'vsf' ? 'vert sf' : 'vsf'

" Share clipboard with OS, it can destroy your normal yank, wtf!
set clipboard=unnamed

" Git commits format:
autocmd Filetype gitcommit setlocal spell textwidth=72

" Remap H and L (top, bottom of screen to left and right end of line)
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L g_

" Quick replay q macro
nnoremap Q @q

" Always show at least X lines above/below cursor
set scrolloff=2

" Same when moving up and down
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap <C-f> <C-f>zz
nnoremap <C-b> <C-b>zz
vnoremap <C-u> <C-u>zz
vnoremap <C-d> <C-d>zz
vnoremap <C-f> <C-f>zz
vnoremap <C-b> <C-b>zz

" Highlight current line, leader+l to highlight, :match to unhighlight
nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

" Error times, from tim pope
set ttimeout
set ttimeoutlen=100

" Fix backspace
set backspace=indent,eol,start
"set backspace=2 " make backspace work like most other apps

" This enables "visual" wrapping
set nowrap

" Uncomment the following to have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" FZF
nnoremap <C-b> :Buffers<CR>
nnoremap <C-g>g :Ag<CR>
nnoremap <C-g>c :Commands<CR>
nnoremap <C-f>l :BLines<CR>
nnoremap <C-p> :Files<CR>

" Emoji stuff I havent actually tested lol
if !has('nvim')     " does not work on neovim
  set emoji         " treat emojis 😄  as full width characters
  set termguicolors " enable true colors - uses gui colors - disable `set -g default-terminal "screen-256color"` from .tmux.conf!
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
end

" This fixes problem with background being bright on lines with text and black
" on lines without text, when using vim inside tmux, and with true color
set t_ut=
" https://github.com/mhartington/oceanic-next/issues/40
" https://github.com/vim/vim/issues/804
" http://stackoverflow.com/questions/6427650/vim-in-tmux-background-color-changes-when-paging/15095377#15095377
