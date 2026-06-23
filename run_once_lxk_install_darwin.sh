#!/bin/bash
set -e

# This script targets macOS (Homebrew-based) systems.
# zsh is the default shell on macOS (Catalina+), so it is NOT installed here.
# On any other OS it is a no-op.
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "[lxk_install_darwin] 非 macOS 系统，跳过安装脚本。"
    exit 0
fi

echo "[1/7] Ensuring Homebrew is installed..."
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Make brew available in this shell (Apple Silicon path first, Intel path fallback).
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "[2/7] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

echo "[3/7] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"

# autojump: on macOS the oh-my-zsh `autojump` plugin (already enabled in dot_zshrc.tmpl)
# sources `$(brew --prefix)/etc/autojump.zsh` for us, so no extra zshrc line is needed.
echo "[4/7] Installing autojump..."
command -v autojump >/dev/null 2>&1 || brew install autojump

echo "[5/7] Installing starship..."
command -v starship >/dev/null 2>&1 || brew install starship

echo "[6/7] Installing tmux + TPM (Tmux Plugin Manager)..."
command -v tmux >/dev/null 2>&1 || brew install tmux
# TPM: clone if missing. Then inside tmux press <prefix> + I to install plugins (e.g. tmux-sensible).
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

echo "[7/7] Done! Start/restart tmux, then press <prefix> + I to load plugins."
