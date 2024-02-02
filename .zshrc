echo "\n(ง •̀_•́)ง\n"

bindkey '^ ' autosuggest-accept

# DO NOT WRITE LOCAL SPECIFIC PATH LIKE MINIO or CQLSH HERE
# INSTEAD PUT IT IN .zshenv
export LC_ALL=en_US.UTF-8
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX=true

ZSH_THEME="robbyrussell"

# ZSH PLUGINS
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh


# TOOLS
if [ -x "$(command -v exa)" ]; then
    alias ls="exa"
    alias la="exa --long --all --group"
fi
if [ -x "$(command -v batcat)" ]; then
    alias cat="batcat"
fi


# PYENV
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"