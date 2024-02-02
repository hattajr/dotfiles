## How to setup

1. Clone the repo in the `$HOME` directory

    ```bash
    git clone https://github.com/hattajr/dotfiles.git ~/dotfiles
    ```
1. Create stow from inside `~/dotfiles`
    ```bash
    stow .
    ```
1. Setup tmux source
    ```
    tmux source-file ~/.config/tmux/tmux.conf
    ```
1. Open `nvim` and `:PluginInstall`
