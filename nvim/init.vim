if exists('g:vscode')
	source ~/.config/nvim/general/vscode_settings.vim
else
	source ~/.config/nvim/general/settings.vim 
	source ~/.config/nvim/keys/mappings.vim 
  source ~/.config/nvim/vim-plug/plugins.vim
  source ~/.config/nvim/after/themes/tokyonight.vim
endif

	


