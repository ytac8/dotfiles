# Set symbolic link
ln -sf ~/ghq/github.com/ytac8/dotfiles/.zshrc ~/.zshrc
ln -sf ~/ghq/github.com/ytac8/dotfiles/.skhdrc ~/.skhdrc
ln -sf ~/ghq/github.com/ytac8/dotfiles/.yabairc ~/.yabairc
ln -sf ~/ghq/github.com/ytac8/dotfiles/config/nvim ~/.config/
ln -sf ~/ghq/github.com/ytac8/dotfiles/config/kitty ~/.config/
ln -sf ~/ghq/github.com/ytac8/dotfiles/config/peco ~/.config/
ln -sf ~/ghq/github.com/ytac8/dotfiles/config/pycodestyle ~/.config/pycodestyle

# brew install
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install btop
brew install cmake
brew install coreutils
brew install curl
brew install fzf
brew install fzy
brew install ghq
brew install git
brew install jesseduffield/lazygit/lazygit
brew install koekeishiya/formulae/skhd
brew install koekeishiya/formulae/yabai
brew install neovim
brew install peco
brew install pyenv
brew install rcm
brew install ripgrep
brew install tig
brew install zsh
