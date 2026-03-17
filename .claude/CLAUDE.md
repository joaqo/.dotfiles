My name is Joaquín Alori, I am a developer from Uruguay, working on several projects.

The biggest project I'm working on now is Mellow, and this is the one I'll usually be refering to if I don't specify.

I also have a ~/.dotfiles project, where I version most of the config files in my machine.
Stuff in ~ like .bashrc, .claude/, .config, my orchestrator agent, etc.
Most of these configs are just symlinks to their version on ~/.dotfiles, so whenever I ask you to modify some config
like this on my OS, first check if its in my dotfiles

Whenever I refer 'my agent' or an 'orchestrator' I'm talking about the agent swift program we defined in ~/.dotfiles/scripts/agent.

In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision. Commit message titles below 72 chars.

## Browser Automation

All browser automation uses **cmux browser** — never Chrome MCP, Chrome DevTools, or `open` commands. Use `/cmux-browser` skill and `cmux browser` CLI for everything: opening pages, clicking, typing, screenshots, JS eval, waiting.

### cmux browser + React
`cmux browser fill/type` don't trigger React's onChange on controlled inputs (WKWebView limitation). Use `eval` with the native setter workaround:
```js
cmux browser <surface> eval "
const input = document.querySelector('<selector>');
const s = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
s.call(input, '<value>');
input.dispatchEvent(new Event('input', { bubbles: true }));
"
```

## Workflow
- Editor: nvim
- Terminal: cmux (use /cmux and /cmux-browser skills for terminal and browser automation)
- Shell: bash
- Python: uv
- Dev servers (vite, expo, next, etc): always start in a new cmux tab (not workspace). Create with `cmux new-surface --type terminal --pane <current-pane>`, rename with `cmux rename-tab --surface <ref> "name"`, send command with `cmux send --surface <ref> "command\n"`. Use descriptive names like `vite-dev`, `expo-dev`.
