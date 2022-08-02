# VSCODE-NEOVIM CONFIG FOR REAL-MEN
 
> **OS: Linux (WSL2)**

1. Clone this repo into your `~/.config` directory.
1. Install Neovim >= v0.5.0 
    ```bash
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install neovim
    ```
1. Install **VSCode-Neovim** extension
1. Because of we use WSL2, we need to specify the `neovimExecutablePaths`, `useWSL : true` and the `neovimInitVimPaths` in your vscode settings.json 
    ```json
    {
      "vscode-neovim.neovimExecutablePaths.linux": "/usr/bin/nvim",
      "vscode-neovim.useWSL": true,
      "vscode-neovim.neovimInitVimPaths.linux": "~/.config/nvim/init.vim"
    }
      ```
1. Install **which-key** vscode extension and copy the **which-key** extension settings from  `setting.json` file into you vscode settings.
1. You also need to copy the `keybindings.json` file into your vscode settings (vscode `keybindings.json`).
  
