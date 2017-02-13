"  ========================= VIM-PLUG =============================
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/jeetsukumaran/vim-indentwise.git'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/w0rp/ale.git'
Plug 'https://github.com/davidhalter/jedi-vim.git'
call plug#end()

" Run google/yapf (not really a plugin but whatever)
autocmd FileType python nnoremap <LocalLeader>= :0,$!yapf<CR>

" Ale only lints on text save, instead of text change
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
" Ale always show left column
let g:ale_sign_column_always = 1
" Ale move between errors
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" =================================================================

colorscheme molokai

runtime! debian.vim
set splitbelow "donde aparecen los nuevos splits
set splitright "donde aparecen los nuevos splits

filetype indent plugin on

" Enable folding
set foldmethod=indent
set foldlevel=99


" Add recursive folders to path (**)
set path=.,/usr/include,,**

" Enable mouse
set mouse=a
set ttymouse=xterm2

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
set wildmenu
set showmatch
set number
set relativenumber
set incsearch
set tabpagemax=400
set ignorecase
map Y y$
set ruler

"" Backup and swap files
set backupdir=~/.vim/tmp/backup/    " where to put backup files.
set directory=~/.vim/tmp/swap/      " where to put swap files.

""" Persistent Undo
"set undofile
"set undodir=~/.vim/tmp/undo

" Show filename, always
set ls=2

" Don't redraw while executing macros (good performance config)
set lazyredraw 

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

"" Tab color Barra de relleno, Tabs no elegidos, Tab elegido
"hi TabLineFill ctermfg=Grey ctermbg=DarkGreen
"hi TabLine ctermfg=231 ctermbg=Grey
"hi TabLineSel ctermfg=231 ctermbg=Black

" Split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" This enables "visual" wrapping
set nowrap

""fix vim diff colors
"highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
"highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
"highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
"highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

" Uncomment the following to have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" -----------Indent Python in the Google way.---------------------
"  ( it probably differs with what yapf working in pep8 mode, but I think
"  there is a google mode too, havent tried it though
" ----------------------------------------------------------------

setlocal indentexpr=GetGooglePythonIndent(v:lnum)

let s:maxoff = 50 " maximum number of lines to look backwards.

function GetGooglePythonIndent(lnum)

  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [par_line, par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
        \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
        \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
        \ . " =~ '\\(Comment\\|String\\)$'")
  if par_line > 0
    call cursor(par_line, 1)
    if par_col != col("$") - 1
      return par_col
    endif
  endif

  " Delegate the rest to the original function.
  return GetPythonIndent(a:lnum)

endfunction

let pyindent_nested_paren="&sw*2"
let pyindent_open_paren="&sw*2"
