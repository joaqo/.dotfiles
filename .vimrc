"================================ VIM-PLUG ==================================
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/jeetsukumaran/vim-indentwise.git'
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
Plug 'christoomey/vim-tmux-navigator'
Plug 'sheerun/vim-polyglot'
call plug#end()
"============================================================================

" ======================= Plug In Configs ===================================
" NERDTree
map <C-n> :NERDTreeToggle<CR>
nnoremap <C-g>n :NERDTreeFind<CR>
let NERDTreeMinimalUI=1

" Git Gutter
set updatetime=250  " Vim update time, defaults to 4000ms
let g:gitgutter_override_sign_column_highlight = 1

" Comfortable vim - scrolling
let g:comfortable_motion_no_default_key_mappings = 1
nnoremap <silent> <C-d> :call comfortable_motion#flick(80)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-80)<CR>

" Ale General configuration
let g:ale_set_highlights = 0  " Dont underline errors/warnings
nmap <silent> <Leader>k <Plug>(ale_previous_wrap)
nmap <silent> <Leader>j <Plug>(ale_next_wrap)
let g:ale_lint_on_save = 0
let g:ale_lint_on_text_changed = 1
let g:ale_sign_column_always = 1
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
hi link ALEErrorSign    GruvboxRed
hi link ALEWarningSign  GruvboxYellow
let g:ale_completion_enabled = 1
let g:ale_linters = {
            \ 'python' : ['pyls'],
            \ }
noremap <silent> gd :ALEGoToDefinition<CR>
noremap <silent> gr :ALEFindReferences<CR>
"
" ALE Statusline function
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? '' : printf(
    \   '%dW|%dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

" Vim-tmux-navigator support for :term
if has('terminal')
    tmap <c-k> <c-w>:TmuxNavigateUp<cr>
    tmap <c-j> <c-w>:TmuxNavigateDown<cr>
    tmap <c-h> <c-w>:TmuxNavigateLeft<cr>
    tmap <c-l> <c-w>:TmuxNavigateRight<cr>
endif

" Polyglot
let g:python_highlight_space_errors = 0
"============================================================================

set splitbelow "donde aparecen los nuevos splits
set splitright "donde aparecen los nuevos splits
set diffopt+=vertical

" TEMPORAL for search/replace
set gdefault

" Enable folding
set foldlevel=99

" Increase command history to 1000 (does not stored repeats!)
set history=1000

" Makes buffers behave more like tabs, not having to save when switching
" buffers and keeping undo history when switching buffers.
set hidden

" 'Stamp' unnamed buffer over visually selected text, not sure if I should keep this
vnoremap S "_d"0P

" Settingds stolen from https://github.com/mcmillion/dotfiles/blob/master/home/.vimrc
set smartcase
set formatoptions-=c                    " Don't auto-wrap comments
set formatoptions+=j                    " Smart join comment lines
set nojoinspaces                        " Don't insert extra spaces after .  when joining
set shortmess+=I                        " Hide splash screen
set switchbuf=usetab                    " Reuse tabs with open buffers

" Prevent vim from looking in included files when using ctrl+n.
" Dont know why it started doing that. Maybe fzf related?
set complete-=i

" ctags
set tags=tags
command Ctags !ctags -R --fields=+l --languages=python --python-kinds=-iv -f ./tags $(python -c "import os, sys; print(' '.join('{}'.format(d) for d in sys.path if os.path.isdir(d)))") ./

" Enable mouse
set mouse=a
if !has('nvim')
    set ttymouse=xterm2
endif

" Syntax
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

" QOL improvements to :term
tmap <C-[> <C-w>N  " Enter normal mode with ESC
tmap <C-w>% <C-w>N:vert term<CR> 
tmap <C-w>" <C-w>N:term<CR> 
nnoremap <C-w>% :vert term<CR> 
nnoremap <C-w>" :term<CR> 

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
nnoremap <C-g>h :History:<CR>
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

" This fixes problem with background being bright on lines with text and black
" on lines without text, when using vim inside tmux, and with true color
" Details: https://github.com/mhartington/oceanic-next/issues/40
"          https://github.com/vim/vim/issues/804
"           http://stackoverflow.com/questions/6427650/vim-in-tmux-background-color-changes-when-paging/15095377#15095377
set t_ut=

" Use :w!! to force write files with sudo
cnoremap w!! %!sudo tee > /dev/null %

" Format json
noremap <silent> <Leader>j :execute '%!python -m json.tool'<CR>

" -- Text editin mode --
noremap <silent> <Leader>t :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Text mode OFF"
    set nu
    set rnu
    setlocal spell! spelllang=en_us
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> k
    silent! nunmap <buffer> j
    silent! nunmap <buffer> H
    silent! nunmap <buffer> L
  else
    echo "Text mode ON"
    set nonu
    set nornu
    setlocal spell! spelllang=en_us
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> k   gk
    noremap  <buffer> <silent> j gj
    noremap  <buffer> <silent> H g<Home>
    noremap  <buffer> <silent> L  g<End>
  endif
endfunction

" " -- Visuals --
let g:gruvbox_termcolors = 16
colorscheme gruvbox
set background=dark
hi Normal ctermbg=0
hi StatusLine ctermbg=red ctermfg=black
set laststatus=2
set noshowmode
" set statusline=%=%f%m\ %P\|%c\ %{LinterStatus()}
set statusline=%{LinterStatus()}%=%f%m\ %P\|%c

" Abbreviations
iabbrev @@i from IPython import embed; embed(display_banner=False)
iabbrev @@d import ipdb; ipdb.set_trace()
iabbrev @@t tf.InteractiveSession; from IPython import embed; embed(display_banner=False)
