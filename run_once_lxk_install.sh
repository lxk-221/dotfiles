#!/bin/bash
set -e

echo "[1/6] Installing zsh..."
command -v zsh &>/dev/null || sudo apt install zsh -y

echo "[2/6] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

echo "[3/6] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"
command -v autojump &>/dev/null || sudo apt-get install -y autojump

echo "[4/6] Installing starship..."
if ! command -v starship &>/dev/null; then
    curl -sSL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz | sudo tar xz -C /usr/local/bin
fi

echo "[5/6] Setting default shell to zsh..."
if [[ "$SHELL" != *zsh* ]]; then
    chsh -s "$(command -v zsh)"
fi

echo "[6/6] Done! Please log out and log back in, then restart tmux (tmux kill-server) for changes to take effect."
