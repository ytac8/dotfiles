# Parse command line arguments
SKIP_FONTS=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-fonts)
      SKIP_FONTS=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--skip-fonts]"
      exit 1
      ;;
  esac
done

# Set symbolic link
DOTFILES_DIR="$HOME/ghq/github.com/ytac8/dotfiles"

# Helper function to create symlink (removes existing dir/file first)
link_config() {
  local src="$1"
  local dest="$2"
  rm -rf "$dest"
  ln -sf "$src" "$dest"
}

ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
link_config "$DOTFILES_DIR/config/aerospace" ~/.config/aerospace
link_config "$DOTFILES_DIR/config/atuin" ~/.config/atuin
link_config "$DOTFILES_DIR/config/borders" ~/.config/borders
link_config "$DOTFILES_DIR/config/ghostty" ~/.config/ghostty
link_config "$DOTFILES_DIR/config/git" ~/.config/git
link_config "$DOTFILES_DIR/config/mise" ~/.config/mise
link_config "$DOTFILES_DIR/config/nvim" ~/.config/nvim
link_config "$DOTFILES_DIR/config/pycodestyle" ~/.config/pycodestyle
link_config "$DOTFILES_DIR/config/sketchybar" ~/.config/sketchybar
link_config "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
link_config "$DOTFILES_DIR/config/zellij" ~/.config/zellij
link_config "$DOTFILES_DIR/config/karabiner" ~/.config/karabiner

# zplug install
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# brew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Set Homebrew PATH for Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew install packages
brew install atuin
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
brew install --cask karabiner-elements
brew install --cask raycast
brew install --cask nikitabobko/tap/aerospace

# git worktree runner
(
  git clone https://github.com/coderabbitai/git-worktree-runner.git /tmp/git-worktree-runner
  cd /tmp/git-worktree-runner
  ./install.sh
  rm -rf /tmp/git-worktree-runner
)

# font
if [ "$SKIP_FONTS" = false ]; then
  bash install_font.sh
else
  echo "Skipping font installation..."
fi

# sketchybar
bash ./config/sketchybar/helpers/install.sh
bash ./config/sketchybar/icon_updater.sh

# start services
brew services start borders
brew services start sketchybar

# mise completion
/opt/homebrew/bin/mise completion zsh  > /opt/homebrew/share/zsh/site-functions/_mise

# claude 
curl -fsSL https://claude.ai/install.sh | bash
