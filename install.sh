#!/usr/bin/env sh

echo "Prepare for installation..."


# apt update
apt-get update

#install curl
apt-get install curl -y
# isntall zsh 
apt-get install zsh -y && zsh --version
# install oh-my-zsh & powerlevel10k
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# install exa : color full ls
apt-get install -y exa
# for ubuntu < 20.01
# wget -c http://old-releases.ubuntu.com/ubuntu/pool/universe/r/rust-exa/exa_0.9.0-4_amd64.deb
# sudo apt-get install ./exa_0.9.0-4_amd64.deb 

# install bat
apt-get install -y bat

# intall git
apt-get install -y git

# install neovim 0.5
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
apt-get install -y neovim

# install vim-plug

