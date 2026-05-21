#!/bin/bash
set -e

# zsh install
sudo apt install zsh -y

# omz install
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# omz plugins
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"
command -v autojump &>/dev/null || sudo apt-get install -y autojump

# starship
curl -sS https://starship.rs/install.sh | sh
