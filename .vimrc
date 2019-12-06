"================================ VIM-PLUG ==================================
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'https://github.com/w0rp/ale.git'
Plug 'https://github.com/elzr/vim-json'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'yuttie/comfortable-motion.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'sheerun/vim-polyglot'
" Plug 'https://github.com/ervandew/supertab'
" Plug 'maralla/completor.vim'
Plug 'https://github.com/roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux-focus-events'  " For vim-tmux-clipboard plugin
" Plug 'ambv/black'
" let g:black_virtualenv = '~/.virtualenvs/black'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()


" ======================= PLUG-IN CONFIGS ===================================
" Supertab
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabClosePreviewOnPopupClose = 1
let g:SuperTabRetainCompletionDuration = 'completion'  " Remembers current completion type

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
" set ruler
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


" ============================== Syntax =====================================
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
au FileType python match Error /\%101v.\+/
au FileType json setlocal
    \ foldmethod=syntax
au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
au BufNewFile,BufRead *.md,*.txt :call ToggleWrap()
autocmd Filetype gitcommit setlocal spell textwidth=72
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
command V e ~/.vimrc
command WQ wq
command W w
command Wq wq
command Q q
command Qa qa
command QA qa
command Wa wa
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L g_
nnoremap Q @q
cnoremap w!! %!sudo tee > /dev/null %
noremap <silent> <Leader>j :execute '%!python -m json.tool'<CR>
noremap <silent> <Leader>t :call ToggleWrap()<CR>
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
let g:gruvbox_termcolors = 16
colorscheme gruvbox
set background=dark
hi Normal ctermbg=0
hi StatusLine ctermbg=red ctermfg=black

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
iabbrev @@i from IPython import embed; embed(display_banner=False)
iabbrev @@d import ipdb; ipdb.set_trace()
iabbrev @@p import pudb; pu.db
iabbrev @@t tf.InteractiveSession; from IPython import embed; embed(display_banner=False)


" ================================ COC =====================================
" Deterimne workspace folder by first looking which folder has a .vim and
" then a .git
let b:coc_root_patterns = ['.vim']

" If hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}%=\ %f%m\ %P\|%c

" " Using CocList
" " Show all diagnostics
" nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" " Manage extensions
" nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" " Show commands
" nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" " Find symbol of current document
" nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" " Search workspace symbols
" nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" " Do default action for next item.
" nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" " Do default action for previous item.
" nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" " Resume latest coc list
" nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
"
