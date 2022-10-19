## setup nvim

note: Assume you have neovim >= 0.5

1. Clone the repo in the `$HOME` directory

    ```bash
    git clone https://github.com/hattajr/dotfiles.git ~/.dotfiles
    ```
1. Install nvim > 0.5

1. Instal vim-plug
	```bash
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	```
1. Install git

1. Install zsh 
    ```bash
	# install zsh & p10k
	sh -c "$(curl -fsSL https://raw.github.com/obbyrussell/oh-my-zsh/master/tools/install.sh)" 
	git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10kr
    ```

1. Create sysmlink directory from `.dotfiles` to `$HOME`

    ```bash
    chmod +x ~/.dotfiles/symlink.sh
    ~/.dotfiles/symlink.sh
    ``````

1. Open `nvim` and `:PluginInstall`
