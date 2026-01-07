# Set symbolic link
DOTFILES_DIR="$HOME/ghq/github.com/ytac8/dotfiles"

ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/.skhdrc" ~/.skhdrc
ln -sf "$DOTFILES_DIR/.yabairc" ~/.yabairc
ln -sf "$DOTFILES_DIR/config/ghostty" ~/.config/
ln -sf "$DOTFILES_DIR/config/git" ~/.config/
ln -sf "$DOTFILES_DIR/config/mise" ~/.config/
ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/
ln -sf "$DOTFILES_DIR/config/pycodestyle" ~/.config/pycodestyle
ln -sf "$DOTFILES_DIR/config/starship.toml" ~/.config/
ln -sf "$DOTFILES_DIR/config/zellij" ~/.config/

# zplug install
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# brew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Set Homebrew PATH for Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

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
brew install koekeishiya/formulae/skhd
brew install koekeishiya/formulae/yabai
brew install luarocks
brew install mise
brew install neovim
brew install rcm
brew install ripgrep
brew install slack
brew install starship
brew install zellij
brew install zoxide

# brew cask
brew install --cask docker
brew install --cask ghostty
brew install --cask raycast

# font
sh install_font.sh

# start services
yabai --start-service
skhd --start-service

# mise completion
/opt/homebrew/bin/mise completion zsh  > /opt/homebrew/share/zsh/site-functions/_mise

# claude 
curl -fsSL https://claude.ai/install.sh | bash
