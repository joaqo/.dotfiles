"================================ Vim-Plug ==================================
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/elzr/vim-json'
Plug 'mhinz/vim-signify'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'yuttie/comfortable-motion.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'https://github.com/roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux-focus-events'  " For vim-tmux-clipboard plugin
Plug 'junegunn/gv.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
call plug#end()


" ========================== Plug-In Configs ================================
" LanguageClient
let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['pyls'],
    \ 'cpp': ['clangd'],
    \ }
" DEBUG: They don't really give a fuck about what color I chose, don't know why.
"        They just set it to black background and white text for some reason.
hi link LanguageClientErrorSign orange
hi link LanguageClientWarningSign orange
hi link LanguageClientInfoSign orange
hi link LanguageClientInfoSign orange
nmap <silent>K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> gr <Plug>(lcn-references)
nmap <silent> <F2> <Plug>(lcn-rename)

" Asyncrun
let g:asyncrun_open = 7  " Number is how many lines it takes in vertical space

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

" Vim Signify
set updatetime=100  " Vim update time defaults to 4000ms
" Left over config from git gutter, if I remove it the sign column gets a background
" color. I have to keep this setting even after deleting gitgutter for some reason.
let g:gitgutter_override_sign_column_highlight = 1
" To print 'Hunk 2/4'
autocmd User SignifyHunk call s:show_current_hunk()
function! s:show_current_hunk() abort
  let h = sy#util#get_hunk_stats()
  if !empty(h)
    echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
  endif
endfunction
" To undo hunk
noremap <silent> <Leader>u :SignifyHunkUndo<CR>
" To show diff in new tab
noremap <silent> <Leader>d :SignifyDiff<CR>
" To preview hunk's diff
noremap <silent> <Leader>p :SignifyHunkDiff<CR>

" Comfortable vim - scrolling
let g:comfortable_motion_no_default_key_mappings = 1
nnoremap <silent> <C-d> :call comfortable_motion#flick(80)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-80)<CR>

" Fugitive
" :G to go to Gstatus and from there you can do whatever or read help

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
set incsearch
set tabpagemax=400
set ignorecase
map Y y$
set noswapfile  " Dont store swap files
set ls=2
set clipboard=unnamed
set scrolloff=2
set backspace=indent,eol,start  " Make backspace work like most other apps
set ttimeout
set ttimeoutlen=100  " Or some vim things are annoyingly slow
set nowrap  " Or long lines wrap around
let g:netrw_silent=1  " Dont ask for an enter-key press after saving an 'scp://' file
set signcolumn=yes  " Always show left debug/diff column so the screen doesn't jump left every time a bug appears
set nocursorcolumn
set nocursorline
set norelativenumber


" ======================== Syntax Highlighting =============================
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
map H ^
map L $
nnoremap Q @q
cnoremap w!! %!sudo tee > /dev/null %
noremap <silent> <Leader>j :execute '%!python -m json.tool'<CR>
noremap <silent> <Leader>t :call ToggleWrap()<CR>
command! -nargs=* S call Sync(<f-args>)

" I did some research and found that _, S, and + are perfect for remapping.
" The key `s` may also be perfect for remapping, taken from this site:
" https://vim.fandom.com/wiki/Unused_keys
" so I am storing this here not to forget about it.
map _ <C-6>

" Run :copen to repoen quickfix window after it auto closes,
" in case you want to confirm which machines synced.
function Sync(...)
  let machines = join(a:000)
  let command = 'sh sync.sh ' . machines . ';echo Done!; sleep 2'
  wa
  call asyncrun#run("!", {'post': 'ccl'}, command)
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
