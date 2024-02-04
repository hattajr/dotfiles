#!/bin/bash

install_apt_get() {
    local app_name="$1"

    # Check if the app exists
    if [ -x "$(command -v $app_name)" ]; then
        echo \> Found $($app_name --version)
    else
        echo \> "'$app_name' not found. Installing..."
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

install_apt() {
    local app_name="$1"

    # Check if the app exists
    if [ -x "$(command -v $app_name)" ]; then
        echo \> Found $($app_name --version)
    else
        echo \> "'$app_name' not found. Installing..."
        # Install the app
        sudo apt update
        sudo apt install -y "$app_name"
        $app_name --version
        # Check installation success or failure
        if [ $? -eq 0 ]; then
            echo \> $($app_name --version) is installed successfully
        else
            echo \> Error: $app_name installation is failed!
        fi
    fi

}
install_apt_get "software-properties-common"
install_apt_get "curl"
install_apt_get "git"
install_apt_get "cargo"
install_apt_get "stow"

# APT install
install_apt "tmux"
install_apt "zsh"

# # ZSH
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# # ZSH PlUGIN
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting




# Install Neovim
if [ -x "$(command -v nvim)" ]; then
    echo \> Found $(nvim --version)
else
    echo "'nvim' not found. Installing..."
    # Install the app
    add-apt-repository ppa:neovim-ppa/unstable \
    && sudo apt-get update \
    && sudo apt-get install -y neovim
    nvim --version
    # Check installation success or failure
    if [ $? -eq 0 ]; then
        echo \> $(nvim --version) is installed successfully
    else
        echo \> Error: nvim installation is failed!
    fi
fi

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'