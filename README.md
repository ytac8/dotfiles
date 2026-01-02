# Dotfiles

Personal dotfiles for macOS development environment.

## Setup

1. Clone this repository:
```bash
git clone https://github.com/ytac8/dotfiles.git ~/ghq/github.com/ytac8/dotfiles
cd ~/ghq/github.com/ytac8/dotfiles
```

2. Create your local environment file:
```bash
cp .zshrc.local.example ~/.zshrc.local
```

3. Edit `~/.zshrc.local` and add your secret values:
```bash
vim ~/.zshrc.local
```

Add your actual API keys and credentials:
```bash
export AWS_PROFILE='your-aws-profile-name'
export CURSOR_API_KEY='your_cursor_api_key_here'
```

4. Run the setup script:
```bash
sh setup.sh
```

## Important Notes

- **DO NOT commit `~/.zshrc.local`** - This file contains your secret API keys and is ignored by git
- `.zshrc.local.example` is a template file that can be safely committed to git
- All absolute paths use `$HOME` variable for portability

## Files

- `.zshrc` - Main zsh configuration (public, tracked by git)
- `.zshrc.local` - Local environment variables (private, NOT tracked by git)
- `.zshrc.local.example` - Template for local environment file
- `setup.sh` - Setup script to create symbolic links
- `install_font.sh` - Install Nerd Fonts
- `config/` - Configuration files for various tools

## Tools Configured

- zsh with zplug
- Neovim
- Starship prompt
- Zellij terminal multiplexer
- Ghostty terminal
- yabai window manager
- skhd hotkey daemon
- mise (version manager)
- and more...
