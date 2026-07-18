#!/bin/bash
set -e

# This script targets macOS (Homebrew-based) systems.
# zsh is the default shell on macOS (Catalina+), so it is NOT installed here.
# On any other OS it is a no-op.
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "[lxk_install_darwin] 非 macOS 系统，跳过安装脚本。"
    exit 0
fi

echo "[1/8] Ensuring Homebrew is installed..."
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Make brew available in this shell (Apple Silicon path first, Intel path fallback).
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "[2/8] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "[3/8] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"

# autojump: on macOS the oh-my-zsh `autojump` plugin (already enabled in dot_zshrc)
# sources `$(brew --prefix)/etc/autojump.zsh` for us, so no extra zshrc line is needed.
echo "[4/8] Installing autojump..."
command -v autojump >/dev/null 2>&1 || brew install autojump

echo "[5/8] Installing starship..."
command -v starship >/dev/null 2>&1 || brew install starship

# 0xProto Nerd Font: starship/others rely on Nerd Font glyphs. The font is NOT
# stored in this repo (binaries don't belong in git, and servers don't render
# fonts anyway). Instead we download the official release zip from
# ryanoasis/nerd-fonts and extract the .ttf files into the macOS per-user font
# directory. macOS picks them up immediately (no font cache refresh needed).
# Idempotent: skip if any one of the expected .ttf files is already present.
echo "[6/8] Installing 0xProto Nerd Font..."
FONT_DIR="$HOME/Library/Fonts"
if [ -f "$FONT_DIR/0xProtoNerdFontMono-Regular.ttf" ]; then
    echo "       0xProto Nerd Font already installed, skipping."
else
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    curl -fsSL -o "$tmpdir/0xProto.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip"
    unzip -o "$tmpdir/0xProto.zip" -d "$tmpdir" >/dev/null
    mkdir -p "$FONT_DIR"
    cp "$tmpdir"/0xProto*.ttf "$FONT_DIR/"
    echo "       Installed 0xProto Nerd Font to $FONT_DIR"
    echo "       Remember to select '0xProto Nerd Font Mono' in iTerm2:"
    echo "         iTerm2 → Settings (Cmd+,) → Profiles → Text → Font"
fi

echo "[7/8] Installing tmux + TPM (Tmux Plugin Manager)..."
command -v tmux >/dev/null 2>&1 || brew install tmux
# TPM: clone if missing. Then inside tmux press <prefix> + I to install plugins (e.g. tmux-sensible).
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

echo "[8/8] Done! Start/restart tmux, then press <prefix> + I to load plugins."
