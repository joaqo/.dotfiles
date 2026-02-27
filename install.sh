# Run me from your home folder

mkdir -p ~/.local/bin

# Download git tools
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > "$HOME/.local/bin/git-prompt.sh"
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "$HOME/.local/bin/git-completion.bash"

ln -s -f .dotfiles/.mcp.json .
ln -s -f .dotfiles/.bashrc .
ln -s -f .dotfiles/.profile .
ln -s -f .dotfiles/.gitconfig .
ln -s -f .dotfiles/.inputrc .
ln -s -f .dotfiles/.tmux.conf .
ln -s -f .dotfiles/.vimrc .
mkdir -p .vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim -c 'PlugInstall' -c 'qa!'

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc  # So we don't get prompts

cd ~/.config
ln -s -f ~/.dotfiles/.config/nvim .
ln -s -f ~/.dotfiles/.config/zed .
ln -s -f ~/.dotfiles/.config/tmuxinator .

mkdir -p "$HOME/Library/Application Support/lazygit"
ln -s -f ~/.dotfiles/.config/lazygit/config.yml "$HOME/Library/Application Support/lazygit/"

mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -s -f ~/.dotfiles/.config/ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/"

mkdir -p ~/.claude
ln -s -f ~/.dotfiles/.claude/CLAUDE.md ~/.claude/
ln -s -f ~/.dotfiles/.claude/settings.json ~/.claude/
ln -s -f ~/.dotfiles/.claude/hooks ~/.claude/
ln -s -f ~/.dotfiles/.claude/commands ~/.claude/

# Build Swift tools
cd ~/.dotfiles/scripts/agent && swiftc -parse-as-library -o agent -framework AppKit -framework SwiftUI main.swift
ln -s -f ~/.dotfiles/scripts/agent/agent ~/.local/bin/agent

cd ~/.dotfiles/scripts/agent/tools/EventKitCLI && swiftc -parse-as-library -o eventkit-cli -framework EventKit -framework CoreLocation main.swift
ln -s -f ~/.dotfiles/scripts/agent/tools/EventKitCLI/eventkit-cli ~/.local/bin/eventkit-cli

ln -s -f ~/.dotfiles/scripts/agent/tools/mellow-task ~/.local/bin/mellow-task
ln -s -f ~/.dotfiles/scripts/agent/tools/mellow-notion ~/.local/bin/mellow-notion
ln -s -f ~/.dotfiles/scripts/agent/lib/iterm-run ~/.local/bin/iterm-run
cd ~

# NvimInITerm — open text/code files in nvim via iTerm
mkdir -p ~/Applications
osacompile -o ~/Applications/NvimInITerm.app ~/.dotfiles/scripts/NvimInITerm.applescript
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.joaqo.NvimInITerm" ~/Applications/NvimInITerm.app/Contents/Info.plist 2>/dev/null
codesign --force --deep --sign - ~/Applications/NvimInITerm.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ~/Applications/NvimInITerm.app
NVIM_BUNDLE="com.joaqo.NvimInITerm"
for uti in public.plain-text public.utf8-plain-text public.source-code public.shell-script public.python-script public.ruby-script public.perl-script public.php-script public.json public.xml public.yaml public.c-source public.c-header public.c-plus-plus-source public.objective-c-source public.swift-source public.assembly-source com.netscape.javascript-source com.apple.log public.css; do
    duti -s "$NVIM_BUNDLE" "$uti" all 2>/dev/null
done
for ext in ts tsx jsx md mdx toml ini cfg conf env csv sql rs go java kt dart lua zig hs elm ex exs erl svelte vue astro graphql gql proto tf tfvars dockerfile makefile; do
    duti -s "$NVIM_BUNDLE" ".$ext" all 2>/dev/null
done

#Language servers
pnpm add -g typescript-language-server tailwindcss-language-server vscode-langservers-extracted
brew install ripgrep
