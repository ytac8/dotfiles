eval "$(zellij setup --generate-auto-start zsh)"

# Load local environment variables (not tracked by git)
# Create ~/.zshrc.local and add your API keys and secrets there
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# for claude
# export AWS_PROFILE='your-profile-name'  # Set your AWS profile in ~/.zshrc.local
export AWS_REGION=ap-northeast-1
export CLAUDE_CODE_USE_BEDROCK=1
export DISABLE_PROMPT_CACHING=1
export ANTHROPIC_MODEL='jp.anthropic.claude-sonnet-4-5-20250929-v1:0'

# for CURSOR
# export CURSOR_API_KEY=your_api_key_here  # Set your API key in ~/.zshrc.local

export EDITOR=nvim
export VISUAL=nvim

# zshrc setting
source ~/.zplug/init.zsh

# starship のconfigファイル設定
eval "$(starship init zsh)"

# mise setting
if type mise > /dev/null; then
  eval "$(mise activate zsh)"
fi

# fzf で ghq で git リポジトリ選択
alias g='cd $(ghq root)/$(ghq list | fzf --reverse)'

# git worktree runner のalias
alias gwr='git gtr'
# git worktree 間移動
function gw() {
  local worktree_path=$(git worktree list | awk '{print $1}' | fzf --reverse --preview 'git -C {} log --oneline -10 --color=always' --preview-window=down:40% --bind 'ctrl-/:toggle-preview')
  if [ -n "$worktree_path" ]; then
    cd "$worktree_path"
  fi
}

# fzf コマンド履歴検索
function fzf-select-history() {
    BUFFER=$(history -n 1 | fzf --query "$LBUFFER" --tac --no-sort --layout=reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# neovim のコンフィグファイルの設定 
export XDG_CONFIG_HOME=$HOME/.config


#terminalの色の設定
export TERM=xterm-256color

# 日本語を使用
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export LC_CTYPE=UTF-8

# パスを追加したい場合
export PATH="$HOME/bin:$PATH"

# 色を使用
autoload -Uz colors
colors

# 補完
autoload -Uz compinit
compinit

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


# エイリアス
#lsの代わりにglsを使う
alias ls='eza'
# vimをneovimにする
alias vim='nvim'
# lazygit
alias lg='lazygit'
# zoxide
eval "$(zoxide init zsh)"
# topの代わりにbtop
alias top='btop'
alias la='ls -la'
alias ll='ls -l'

# historyに日付を表示
alias h='fc -lt '%F %T' 1'
alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias diff='diff -U1'

# backspace,deleteキーを使えるように
stty erase ^H
bindkey "^[[3~" delete-char

# cdの後にlsを実行
chpwd() { ls -l }

# どこからでも参照できるディレクトリパス
cdpath=(~)

############################### 
# zplug
############################### 

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "mrowa44/emojify", as:command
zplug "mafredri/zsh-async", from:github
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

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

# google cloud sdk setting
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/src/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/src/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/src/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/src/google-cloud-sdk/completion.zsh.inc"; fi



# profiling
if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

export PATH="$HOME/.local/bin:$PATH"

# git gtr setting
export PATH="$PATH:$HOME/ghq/github.com/coderabbitai/git-worktree-runner/bin"
ulimit -n 10240
