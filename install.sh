# Run me from your home folder

mkdir -p ~/.local/bin

# Download git tools
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > "$HOME/.local/bin/git-prompt.sh"
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "$HOME/.local/bin/git-completion.bash"

# Symlink custom scripts from dotfiles/bin to ~/.local/bin
for script in ~/.dotfiles/bin/*; do
  ln -sf "$script" ~/.local/bin/
done

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

mkdir -p "$HOME/Library/Application Support/lazygit"
ln -s -f ~/.dotfiles/.config/lazygit/config.yml "$HOME/Library/Application Support/lazygit/"

#Language servers
pnpm add -g typescript-language-server tailwindcss-language-server vscode-langservers-extracted
brew install ripgrep
