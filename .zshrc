# solarizedの設定
alias ls='gls --color=auto'
eval $(gdircolors ~/.config/dircolors-solarized)

# vimをneovimにする
alias vim='nvim'

# neovim のコンフィグファイルの設定
export XDG_CONFIG_HOME=$HOME/.config

# pyenvのpath設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$PYENV_ROOT/versions/anaconda3-4.2.0/bin:$PATH"
