#!/bin/bash

install_apt() {
    local app_name="$1"

    # Check if the app exists
    if [ -x "$(command -v $app_name)" ]; then
        echo \> Found $($app_name --version)
    else
        echo \> '$app_name' not found. Installing...
        # Install the app
        sudo apt-get update
        sudo apt-get install -y "$app_name"
        $app_name --version
        # Check installation success or failure
        if [ $? -eq 0 ]; then
            echo \> $($app_name --version) is installed successfully
        else
            echo \> Error: $app_name installation is failed!
        fi
    fi

}

install_apt "software-properties-common"

install_apt "git"

install_apt "curl"

install_apt "zsh"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

install_apt "cargo"
install_apt "stow"

# APT install
apt install tmux


# Install Neovim
if [ -x "$(command -v nvim)" ]; then
    echo \> Found $(nvim --version)
else
    echo "'nvim' not found. Installing..."
    # Install the app
    add-apt-repository ppa:neovim-ppa/unstable \
    && sudo apt-get update \
    && sudo apt-get install -y neovim
    $app_name --version
    # Check installation success or failure
    if [ $? -eq 0 ]; then
        echo \> $($app_name --version) is installed successfully
    else
        echo \> Error: $app_name installation is failed!
    fi
fi





# install exa : color full ls
#apt-get install -y exa
# for ubuntu < 20.01
# wget -c http://old-releases.ubuntu.com/ubuntu/pool/universe/r/rust-exa/exa_0.9.0-4_amd64.deb
# sudo apt-get install ./exa_0.9.0-4_amd64.deb 

# install vim-plug