# Run me from your home folder

mkdir -p ~/.bin
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh --directory-prefix="$HOME/.bin/"
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash --directory-prefix="$HOME/.bin/"
ln -s -f .dotfiles/.bashrc .
ln -s -f .dotfiles/.profile .
ln -s -f .dotfiles/.gitconfig .
ln -s -f .dotfiles/.inputrc .
ln -s -f .dotfiles/.tmux.conf .
ln -s -f .dotfiles/.vimrc .
ln -s -f .dotfiles/.vimrc_coc .
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim -c 'PlugInstall' -c 'qa!'
