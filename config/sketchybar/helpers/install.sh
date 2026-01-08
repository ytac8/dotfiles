# Packages
brew install lua
brew install switchaudio-osx
brew install nowplaying-cli

brew tap FelixKratz/formulae

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
curl -L https://github.com/SoichiroYamane/sketchybar-app-font-bg/releases/download/v0.0.2/sketchybar-app-font-bg.ttf -o $HOME/Library/Fonts/sketchybar-app-font-bg.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
