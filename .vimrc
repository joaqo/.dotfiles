"================================ VIM-PLUG ==================================
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/jeetsukumaran/vim-indentwise.git'
Plug 'maralla/completor.vim'
Plug 'morhetz/gruvbox'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/w0rp/ale.git'
Plug 'https://github.com/elzr/vim-json'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'yuttie/comfortable-motion.vim'
call plug#end()
"============================================================================

" ======================= Plug In Configs ===================================
" NERDTree
map <C-n> :NERDTreeToggle<CR>
nnoremap <C-g>n :NERDTreeFind<CR>
" let NERDTreeQuitOnOpen=1
let NERDTreeMinimalUI=1

" Ale
let g:ale_statusline_format = ['☀️️ %d', '🕯️ %d', '']
let g:ale_set_highlights = 0  " Dont underline errors/warnings
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
let g:ale_lint_on_save = 0
let g:ale_lint_on_text_changed = 1
let g:ale_sign_column_always = 1

" Git Gutter
set updatetime=250  " Vim update time, defaults to 4000ms
let g:gitgutter_override_sign_column_highlight = 1

" Comfortable vim - scrolling
let g:comfortable_motion_no_default_key_mappings = 1
nnoremap <silent> <C-d> :call comfortable_motion#flick(80)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-80)<CR>

let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
hi link ALEErrorSign    GruvboxRed
hi link ALEWarningSign  GruvboxYellow
"============================================================================

" Run google/yapf (not really a plugin but whatever)
autocmd FileType python nnoremap <LocalLeader>= :0,$!yapf<CR>

set splitbelow "donde aparecen los nuevos splits
set splitright "donde aparecen los nuevos splits
set diffopt+=vertical

"filetype indent plugin on

" Enable folding
set foldlevel=99

" Makes buffers behave more like tabs, not having to save when switching
" buffers and keeping undo history when switching buffers.
set hidden

" Prevent vim from looking in included files when using ctrl+n.
" Dont know why it started doing that. Maybe fzf related?
set complete-=i

" ctags
set tags=tags
command Ctags !ctags -R --fields=+l --languages=python --python-kinds=-iv -f ./tags $(python -c "import os, sys; print(' '.join('{}'.format(d) for d in sys.path if os.path.isdir(d)))") ./
" " Case sensitive ctags when having case insensitive search activated, not sure if necesary
" fun! MatchCaseTag()
"     let ic = &ic
"     set noic
"     try
"         exe 'tjump ' . expand('<cword>')
"     finally
"        let &ic = ic
"     endtry
" endfun
" nnoremap <silent> <c-]> :call MatchCaseTag()<CR>


" " Add recursive folders to path (**)
" set path=.,/usr/include,,**

" Enable mouse
set mouse=a
if !has('nvim')
    set ttymouse=xterm2
endif

syntax on

au FileType c setlocal
    \ tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ noexpandtab

au FileType python setlocal
    \ tabstop=8
    \ softtabstop=4
    \ shiftwidth=4
    \ expandtab
    \ autoindent
    \ fileformat=unix
    \ foldmethod=indent

" " This can make openinig big jsons quite slow
" au FileType json setlocal
"     \ foldmethod=syntax

" au BufNewFile,BufRead *.py
"     \ match ErrorMsg '\%>100v.\+'

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |

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
highlight clear ALEErrorSign
highlight clear ALEWarningSign
highlight clear SignColumn

" Show filename, always
set ls=2

set lazyredraw  " Don't redraw while executing macros (good performance config)
set ttyfast     " should make scrolling faster

" Open ~/.vimrc. (~/.vimrc should be a symlink to .dotfiles/.vimrc)
command V e ~/.vimrc

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

" ======= FZF =============
nnoremap <C-b> :Buffers<CR>
nnoremap <C-f> :GGrep<CR>
nnoremap <C-g>a :Ag<CR>
nnoremap <C-g>c :Commands<CR>
nnoremap <C-g>h :History<CR>
nnoremap <C-g>l :BLines<CR>
nnoremap <C-g>g :GFiles<CR>
nnoremap <C-p> :Files<CR>

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \                         : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%'),
  \                 <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--no-hscroll --delimiter : --nth 3..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--no-hscroll --delimiter : --nth 3..'}, 'right:50%'),
  \   <bang>0)
" ==========================

" Emoji stuff I havent actually tested lol
if !has('nvim')     " does not work on neovim
  set emoji         " treat emojis 😄  as full width characters
  set termguicolors " enable true colors - uses gui colors - disable `set -g default-terminal "screen-256color"` from .tmux.conf!
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
end

" This fixes problem with background being bright on lines with text and black
" on lines without text, when using vim inside tmux, and with true color
" Details:
" https://github.com/mhartington/oceanic-next/issues/40
" https://github.com/vim/vim/issues/804
" http://stackoverflow.com/questions/6427650/vim-in-tmux-background-color-changes-when-paging/15095377#15095377
set t_ut=

" :w!! 
" write the file when you accidentally opened it without the right (root) privileges
cmap w!! w !sudo tee % > /dev/null

" -- Text editin mode --
noremap <silent> <Leader>t :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Text mode OFF"
    setlocal spell! spelllang=en_us
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> k
    silent! nunmap <buffer> j
    silent! nunmap <buffer> H
    silent! nunmap <buffer> L
    " silent! iunmap <buffer> k
    " silent! iunmap <buffer> j
    " silent! iunmap <buffer> H
    " silent! iunmap <buffer> L
  else
    echo "Text mode ON"
    setlocal spell! spelllang=en_us
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> k   gk
    noremap  <buffer> <silent> j gj
    noremap  <buffer> <silent> H g<Home>
    noremap  <buffer> <silent> L  g<End>
    " inoremap <buffer> <silent> k <C-o>gk
    " inoremap <buffer> <silent> j <C-o>gj
    " inoremap <buffer> <silent> H <C-o>g<Home>
    " inoremap <buffer> <silent> L  <C-o>g<End>
  endif
endfunction

" -- Visuals --
set background=dark
colorscheme gruvbox
highlight clear StatusLine
hi vertsplit ctermfg=238 ctermbg=235
hi LineNr ctermfg=237
hi StatusLine ctermfg=235 ctermbg=245
hi StatusLineNC ctermfg=235 ctermbg=37
hi Search ctermbg=58 ctermfg=15
hi Default ctermfg=1
hi clear SignColumn
hi SignColumn ctermbg=235
hi EndOfBuffer ctermfg=237 ctermbg=235

set statusline=%=%f%m\ %P\ %c\ %{ALEGetStatusLine()}\ %{fugitive#statusline()}

set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set noshowmode
hi Normal guibg=Black

" " -- Drawer --
" let g:netrw_banner = 0
" let g:netrw_liststyle = 3
" let g:netrw_browse_split = 4
" let g:netrw_altv = 1
" let g:netrw_winsize = 20
