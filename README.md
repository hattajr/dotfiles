## setup nvim

note: Assume you have neovim >= 0.5

1. clone the repo in the `$HOME` directory

    ```bash
    git clone https://github.com/hattajr/dotfiles.git ~/.dotfiles
    ```

2. Create sysmlink directory from `.dotfiles` to `$HOME`

    ```bash
    chmod +x ~/.dotfiles/symlink.sh
    ~/.dotfiles/symlink.sh

3. Open `nvim` and `:PluginInstall`
