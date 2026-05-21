#!/bin/bash
set -e

echo "[1/5] Installing zsh..."
command -v zsh &>/dev/null || sudo apt install zsh -y

echo "[2/5] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

echo "[3/5] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"
command -v autojump &>/dev/null || sudo apt-get install -y autojump

echo "[4/5] Installing starship..."
command -v starship &>/dev/null || curl -sS https://starship.rs/install.sh | sh

echo "[5/5] Done!"
