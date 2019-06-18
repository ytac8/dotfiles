# zshrc setting
source ~/.zplug/init.zsh

#lsの代わりにglsを使う
alias ls='gls --color=auto'
# vimをneovimにする
alias vim='nvim'

#GO setting
export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
eval "$(goenv init -)"

# neovim のコンフィグファイルの設定 
export XDG_CONFIG_HOME=$HOME/.config

# scala setting
export PATH="${HOME}/.scalaenv/bin:${PATH}"
eval "$(scalaenv init -)"
export JAVA_HOME='/usr/libexec/java_home -v 1.8'

# pyenvのpath設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# node path setting
export PATH=$HOME/.nodebrew/current/bin:$PATH

#terminalの色の設定
export TERM=xterm-256color

# 日本語を使用
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# 色を使用
autoload -Uz colors
colors

# 補完
autoload -Uz compinit
compinit

# emacsキーバインド
bindkey -v

# 他のターミナルとヒストリーを共有
setopt share_history

# ヒストリーに重複を表示しない
setopt histignorealldups

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# コマンドミスを修正
setopt correct


# グローバルエイリアス
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'


# エイリアス
alias lst='ls -ltr --color=auto'
alias l='ls -ltr --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -l --color=auto'
alias so='source'
alias vz='vim ~/.zshrc'
alias c='cdr'
# historyに日付を表示
alias h='fc -lt '%F %T' 1'
alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias ..='c ../'
alias back='pushd'
alias diff='diff -U1'

# backspace,deleteキーを使えるように
stty erase ^H
bindkey "^[[3~" delete-char

# cdの後にlsを実行
chpwd() { ls -ltr --color=auto }

# どこからでも参照できるディレクトリパス
cdpath=(~)


# Ctrl+rでヒストリーのインクリメンタルサーチ、Ctrl+sで逆順
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

# コマンドを途中まで入力後、historyから絞り込み
# 例 ls まで打ってCtrl+pでlsコマンドをさかのぼる、Ctrl+bで逆順
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^b" history-beginning-search-forward-end

# cdrコマンドを有効 ログアウトしても有効なディレクトリ履歴
# cdr タブでリストを表示
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs


# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

# mkdirとcdを同時実行
function mkcd() {
  if [[ -d $1 ]]; then
    echo "$1 already exists!"
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}


##############################
# peco setting
##############################

# peco ghq home dir
peco-src() {
    local selected
    selected="$(ghq list --full-path | peco --query="$LBUFFER")"
    if [ -n "$selected" ]; then
        BUFFER="cd $selected"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# peco historical search
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

############################### 
# zplug
############################### 


zplug "zsh-users/zsh-history-substring-search"
zplug "mollifier/anyframe"
zplug "mollifier/cd-gitroot"
zplug "stedolan/jq", from:gh-r, as:command, \
    on: zplug "b4b4r07/emoji-cli", if:"which jq"
zplug "b4b4r07/enhancd", use:init.sh
zplug "hchbaw/opp.zsh"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "mrowa44/emojify", as:command
zplug "peco/peco", as:command, from:gh-r
zplug "b4b4r07/zsh-gomi", as:command, use:bin, rename-to:rm

zplug "junegunn/fzf-bin", \
    as:command, \
    rename-to:"fzf", \
    from:gh-r, \
    use:"*darwin*amd64*"

zplug "motemen/ghq", \
    as:command, \
    from:gh-r, \
    rename-to:ghq

zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# 未インストール項目をインストールする
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load

# 区切り文字の設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "_-./;@"
zstyle ':zle:*' word-style unspecified

# Ctrl+sのロック, Ctrl+qのロック解除を無効にする
setopt no_flow_control


# 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*:default' menu select=2

# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


