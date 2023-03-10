# Run me from your home folder

mkdir -p ~/.bin
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > "$HOME/.bin/git-prompt.sh"
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "$HOME/.bin/git-completion.bash"
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
