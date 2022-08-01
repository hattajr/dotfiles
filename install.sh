#!/usr/bin/env sh

echo "Prepare for installation..."


# apt update
apt-get update

#install curl
apt-get install curl -y
# isntall zsh 
apt-get install zsh -y && zsh --version

# install exa : color full ls
apt-get install -y exa

# intall git
apt-get install -y git

# install neovim
apt-get install -y neovim

# install vim-plug


# install oh-my-zsh & powerlevel10k
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k