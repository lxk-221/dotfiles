#!/bin/bash
set -e

# This script targets Debian/Ubuntu (apt-based) systems.
# On any other OS / package manager it is a no-op.
if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt-get >/dev/null 2>&1; then
    echo "[lxk_install] 非 Linux/apt 系统，跳过安装脚本。"
    exit 0
fi

echo "[1/7] Installing zsh..."
command -v zsh &>/dev/null || sudo apt install zsh -y

echo "[2/7] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

echo "[3/7] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"
command -v autojump &>/dev/null || sudo apt-get install -y autojump

echo "[4/7] Installing starship..."
if ! command -v starship &>/dev/null; then
    curl -sSL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz | sudo tar xz -C /usr/local/bin
fi

echo "[5/7] Setting default shell to zsh..."
if [[ "$SHELL" != *zsh* ]]; then
    chsh -s "$(command -v zsh)"
fi

echo "[6/7] Installing fcitx5 (Chinese input, 微软双拼) and xsel (tmux clipboard)..."
if ! command -v fcitx5 &>/dev/null; then
    sudo apt-get install -y fcitx5 fcitx5-chinese-addons fcitx5-config-qt \
        fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 im-config
fi
# xsel: tmux copy-mode 'y' pipes the selection to the X11 clipboard
command -v xsel >/dev/null 2>&1 || sudo apt-get install -y xsel
# Activate fcitx5 as the input method framework (writes ~/.xinputrc); idempotent.
im-config -n fcitx5

echo "[7/7] Done! Log out and back in for changes to take effect (needed for both the default shell and fcitx5), then restart tmux (tmux kill-server)."
