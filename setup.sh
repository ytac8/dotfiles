# Set symbolic link
DOTFILES_DIR="$HOME/ghq/github.com/ytac8/dotfiles"

ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/config/aerospace" ~/.config/
ln -sf "$DOTFILES_DIR/config/borders" ~/.config/
ln -sf "$DOTFILES_DIR/config/ghostty" ~/.config/
ln -sf "$DOTFILES_DIR/config/git" ~/.config/
ln -sf "$DOTFILES_DIR/config/mise" ~/.config/
ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/
ln -sf "$DOTFILES_DIR/config/pycodestyle" ~/.config/pycodestyle
ln -sf "$DOTFILES_DIR/config/sketchybar" ~/.config/
ln -sf "$DOTFILES_DIR/config/starship.toml" ~/.config/
ln -sf "$DOTFILES_DIR/config/zellij" ~/.config/

# zplug install
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# brew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Set Homebrew PATH for Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew install packages
brew install btop
brew install cmake
brew install coreutils
brew install curl
brew install eza
brew install fd
brew install fzf
brew install gh
brew install ghq
brew install git
brew install git-delta
brew install google-chrome
brew install google-japanese-ime
brew install jesseduffield/lazygit/lazygit
brew install lazydocker
brew install jq
brew install luarocks
brew install mise
brew install neovim
brew install pnpm
brew install rcm
brew install ripgrep
brew install slack
brew install starship
brew install zellij
brew install zoxide

# tap and install
brew tap FelixKratz/formulae && brew install borders
brew tap FelixKratz/formulae && brew install sketchybar

# brew cask
brew install --cask alt-tab
brew install --cask docker
brew install --cask ghostty
brew install --cask raycast
brew install --cask nikitabobko/tap/aerospace

# font
sh install_font.sh

# sketchybar
./config/sketchybar/helpers/install.sh
./config/sketchybar/icon_updater.sh

# start services
brew services start borders
brew services start sketchybar

# mise completion
/opt/homebrew/bin/mise completion zsh  > /opt/homebrew/share/zsh/site-functions/_mise

# claude 
curl -fsSL https://claude.ai/install.sh | bash
