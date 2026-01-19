# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

```
init.lua                    # entry point, requires config modules in order
lua/
├── config/
│   ├── terminal.lua        # ToggleTerminal(), loaded first
│   ├── options.lua         # vim.opt settings
│   ├── lazy.lua            # lazy.nvim bootstrap + plugin loader
│   ├── keymaps.lua         # global keybindings
│   └── autocmds.lua        # autocommands
└── plugins/                # one file per plugin (lazy.nvim specs)
```

Load order: terminal → options → lazy (loads plugins/) → keymaps → autocmds

## Key Settings

- Leader: `;`
- Space remapped to `:`
- 2-space indent, no swapfile
- Line start/end: `H`/`L` (replaces `^`/`$`)
- Repeat motion: `)`/`(` (replaces `;`/`,`)

## Critical Keybindings

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle terminal |
| `\` | Toggle neo-tree |
| `<leader>f` | Find files |
| `<leader>/` | Live grep (ripgrep) |
| `<leader>,` | Switch buffer |
| `gd` | Go to definition |
| `K` | Hover docs |
| `grr` | References |
| `gra` | Code action |
| `grn` | Rename |
| `gri` | Implementation |
| `<leader>gf` | LSP format |
| `<leader>F` | Neoformat |
| `]h`/`[h` | Next/prev git hunk |
| `<leader>hs` | Stage hunk |
| `<C-hjkl>` | Tmux/nvim pane nav |

## LSP

Servers: pyright, ts_ls, tailwindcss, eslint

Configured in `plugins/lsp.lua`. All share same `on_attach` for keymaps.

Diagnostics: `<leader>d` (float), `[d`/`]d` (nav), `<leader>Q` (quickfix)

## Completion (nvim-cmp)

Sources: lsp → luasnip → buffer → path

`<C-n>`/`<C-p>` nav, `<C-Space>` trigger, `<CR>` confirm

## Colorscheme

gruvbox with transparent background. Custom highlights for search, gitsigns, neo-tree in `plugins/colorscheme.lua`.

## External Dependencies

Required: git, ripgrep

LSP servers (npm -g): pyright, typescript-language-server, tailwindcss-language-server, vscode-langservers-extracted

## Treesitter

24 langs, python indent disabled. Config in `plugins/treesitter.lua`.

## Terminal

`ToggleTerminal()` in config/terminal.lua - auto-closes neo-tree, preserves window state. Bound to `<C-\>`.

## Style

Be concise. Match existing patterns. Don't add plugins unless necessary.
