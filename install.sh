# Run me from your home folder

wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh --directory-prefix=/usr/local/etc/bash_completion.d/
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash --directory-prefix=/usr/local/etc/bash_completion.d/
ln -s -f .dotfiles/.bashrc .
ln -s -f .dotfiles/.profile .
ln -s -f .dotfiles/.gitconfig .
ln -s -f .dotfiles/.inputrc .
ln -s -f .dotfiles/.tmux.conf .
ln -s -f .dotfiles/.vimrc .
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim -c 'PlugInstall' -c 'qa!'
