"================================ VIM-PLUG ==================================
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/elzr/vim-json'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'yuttie/comfortable-motion.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'sheerun/vim-polyglot'
Plug 'https://github.com/roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux-focus-events'  " For vim-tmux-clipboard plugin
Plug 'junegunn/gv.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

highlight CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
set cursorline


" ======================= PLUG-IN CONFIGS ===================================

" NERDTree
function! NERDTreeToggleInCurDir()
    " If NERDTree is open in the current buffer
    if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
        exe ":NERDTreeClose"
    else
        if (expand("%:t") != '')
            exe ":NERDTreeFind"
        else
            exe ":NERDTreeToggle"
        endif
    endif
endfunction

map <C-n> :call NERDTreeToggleInCurDir()<CR>
let NERDTreeMinimalUI=1

" Git Gutter
set updatetime=250  " Vim update time, defaults to 4000ms
let g:gitgutter_override_sign_column_highlight = 1

" Comfortable vim - scrolling
let g:comfortable_motion_no_default_key_mappings = 1
nnoremap <silent> <C-d> :call comfortable_motion#flick(80)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-80)<CR>

" Polyglot
let g:python_highlight_space_errors = 0
let g:vim_markdown_new_list_item_indent = 0  " https://github.com/plasticboy/vim-markdown

" Fugitive
command S vertical Gstatus

" FZF
nnoremap <C-f> :GGrep<CR>
nnoremap <C-p> :Files<CR>
nnoremap <C-b> :Buffers<CR>
nnoremap <C-g>w :GGrepCword<CR>
nnoremap <C-g>a :Ag<CR>
nnoremap <C-g>c :Commands<CR>
nnoremap <C-g>h :History:<CR>
nnoremap <C-g>f :BLines<CR>
nnoremap <C-g>l :BLines<CR>
nnoremap <C-g>g :GFiles<CR>

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

command! -bang -nargs=* GGrepCword
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--no-hscroll --delimiter : --nth 3.. -q '.shellescape(expand('<cword>'))}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--no-hscroll --delimiter : --nth 3.. -q '.shellescape(expand('<cword>'))}, 'right:50%'),
  \   <bang>0)


" ======================== Set defaults =====================================
set splitbelow  " Donde aparecen los nuevos splits
set splitright  " Donde aparecen los nuevos splits
set diffopt+=vertical
set gdefault  " TEMPORAL for search/replace
set foldlevel=99  " Enable folding
set history=1000  " Increase command history to 1000 (does not stored repeats!)
set hidden  " Makes buffers behave more like tabs, not having to save when switching buffers and keeping undo history when switching buffers.
set smartcase
set formatoptions+=j  " Smart join comment lines
set nojoinspaces  " Don't insert extra spaces after .  when joining
set shortmess+=I  " Hide splash screen
set mouse=a  " Enable mouse
set ttymouse=xterm2  " Fixes some mouse bugs when using vim+tmux
set showmatch
set number
set relativenumber
set incsearch
set tabpagemax=400
set ignorecase
map Y y$
set noswapfile  " Dont store swap files
set ls=2
" set lazyredraw  " Don't redraw while executing macros (good performance config)
" set ttyfast     " should make scrolling faster
set clipboard=unnamed
set scrolloff=2
set backspace=indent,eol,start  " Make backspace work like most other apps
" set backspace=2 
set ttimeout
set ttimeoutlen=100  " Or some vim things are annoyingly slow
set nowrap  " Or long lines wrap around
let g:netrw_silent=1  " Dont ask for an enter-key press after saving an 'scp://' file
" let g:pyindent_searchpair_timeout=10  " Not sure if it is needed, from: https://github.com/vim/vim/issues/1098
set signcolumn=yes  " Always show left debug/diff column so the screen doesn't jump left every time a bug appears


" ============================== Syntax =====================================
syntax on
au FileType c setlocal
    \ tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ noexpandtab
au FileType cpp setlocal
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
au FileType json setlocal
    \ foldmethod=syntax
au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
au BufNewFile,BufRead *.md,*.txt :call ToggleWrap()
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd BufNewFile,BufRead *.png,*.jpg,*gif exec "! /usr/bin/imgcat ".expand("%") | :bw
"
" Highlight TODO, FIXME, NOTE, etc.
if has('autocmd') && v:version > 701
    augroup todo
        autocmd!
        autocmd Syntax * call matchadd(
                    \ 'Debug',
                    \ '\v\W\zs<(NOTE|INFO|IDEA|TODO|FIXME|CHANGED|XXX|BUG|HACK|TRICKY)>'
                    \ )
    augroup END
endif


" ============================== Remaps ======================================
" n  Normal mode map. Defined using ':nmap' or ':nnoremap'.
" i  Insert mode map. Defined using ':imap' or ':inoremap'.
" v  Visual and select mode map. Defined using ':vmap' or ':vnoremap'.
" x  Visual mode map. Defined using ':xmap' or ':xnoremap'.
" s  Select mode map. Defined using ':smap' or ':snoremap'.
" c  Command-line mode map. Defined using ':cmap' or ':cnoremap'.
" o  Operator pending mode map. Defined using ':omap' or ':onoremap'.
" IMPORTANT: Use `:verbose nmap <keys>` to chech already used maps before adding new ones.
"            It doesn't seem to work with default vim keys though, wtf.
command V e ~/.vimrc
command WQ wq
command W w
command Wq wq
command Q q
command Qa qa
command QA qa
command Wa wa
" This fixes things like dH (deleting till start of line) not working.
" Remove these comments after testing it thoroughly
" nnoremap H ^
" nnoremap L $
" vnoremap H ^
" vnoremap L g_
map H ^
map L $
nnoremap Q @q
cnoremap w!! %!sudo tee > /dev/null %
noremap <silent> <Leader>j :execute '%!python -m json.tool'<CR>
noremap <silent> <Leader>t :call ToggleWrap()<CR>
command! -nargs=* S call Sync(<f-args>)

" Arguments are referenced using 'a:'
" The string concatenation operator is: '.'
function Sync(...)
  let machine = a:0 >= 1 ? a:1 : "dev"
  let command = '!sh sync.sh '
  w
  silent execute command . machine  
  redraw!
  echo "Synced " . machine
endfunction

function ToggleWrap()
  if &wrap
    set nu
    set rnu
    " setlocal spell! spelllang=en_us
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> k
    silent! nunmap <buffer> j
    silent! nunmap <buffer> H
    silent! nunmap <buffer> L
  else
    set nonu
    set nornu
    " setlocal spell! spelllang=en_us
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> k   gk
    noremap  <buffer> <silent> j gj
    noremap  <buffer> <silent> H g<Home>
    noremap  <buffer> <silent> L  g<End>
  endif
endfunction

" Remap Space to : in normal mode
nnoremap <Space> :

" Bind p in visual mode to paste without overriding the current register
vnoremap p pgvy


" ============================== Looks =====================================
colorscheme gruvbox
set background=dark | hi Normal ctermbg=0 | hi StatusLine ctermbg=red ctermfg=black
hi CocErrorHighlight cterm=underline
hi CocWarningHighlight cterm=underline
hi CocInfoHighlight cterm=underline
hi CocHintHighlight cterm=underline

command L set background=light | hi Normal ctermbg=white | hi StatusLine ctermbg=red ctermfg=white
command D set background=dark | hi Normal ctermbg=0 | hi StatusLine ctermbg=red ctermfg=black

let s:hidden_all = 0
function ToggleStatusBar()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=1
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
call ToggleStatusBar()
command SB call ToggleStatusBar()


" =========================== Abbreviations ================================
iabbrev @@b breakpoint()
iabbrev @@d import bpdb; bpdb.set_trace()
iabbrev @@p import pudb; pu.db
iabbrev @@t tf.InteractiveSession; from IPython import embed; embed(display_banner=False)


" ========================== Other vim configs ===============================
source ~/.vimrc_coc
