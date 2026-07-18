#!/bin/bash
set -e

# This script targets Debian/Ubuntu and other apt-based Linux distros.
# The filename uses the generic `_linux` token for symmetry with
# `_darwin.sh` and alignment with chezmoi's `.chezmoi.os == "linux"` check,
# but the actual scope is narrower: the guard below requires `apt-get`, so
# non-apt distros (Arch, Fedora, Alpine, ...) no-op here even though they
# are Linux too. If you ever need to support another package manager, add a
# sibling script (e.g. run_once_lxk_install_linux_arch.sh) rather than
# branching this one.
if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt-get >/dev/null 2>&1; then
    echo "[lxk_install_linux] 非 Linux/apt 系统，跳过安装脚本。"
    exit 0
fi

echo "[1/9] Installing zsh..."
sudo apt-get update
command -v zsh &>/dev/null || sudo apt install zsh -y

echo "[2/9] Installing oh-my-zsh..."
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "[3/9] Installing zsh plugins..."
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$dir"
dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d "$dir" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$dir"
command -v autojump &>/dev/null || sudo apt-get install -y autojump

echo "[4/9] Installing starship..."
if ! command -v starship &>/dev/null; then
    curl -sSL https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz | sudo tar xz -C /usr/local/bin
fi

# 0xProto Nerd Font: only useful on a Linux box with a desktop/GUI terminal.
# Headless servers don't render fonts (your local terminal does, over SSH), so
# skip entirely when there's no DISPLAY. The download URL is the same as macOS
# (ryanoasis/nerd-fonts latest release); only the install location + cache
# refresh differ. Font files are NOT stored in this repo — see the macOS script
# for the same rationale.
echo "[5/9] Installing 0xProto Nerd Font (desktop only)..."
if [ -z "${DISPLAY:-}" ]; then
    echo "       No \$DISPLAY (headless server) — fonts are rendered by your"
    echo "       local terminal over SSH, so skipping font install here."
else
    FONT_DIR="$HOME/.local/share/fonts"
    if [ -f "$FONT_DIR/0xProtoNerdFontMono-Regular.ttf" ]; then
        echo "       0xProto Nerd Font already installed, skipping."
    else
        command -v unzip >/dev/null 2>&1 || sudo apt-get install -y unzip
        command -v fc-cache >/dev/null 2>&1 || sudo apt-get install -y fontconfig
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT
        curl -fsSL -o "$tmpdir/0xProto.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip"
        unzip -o "$tmpdir/0xProto.zip" -d "$tmpdir" >/dev/null
        mkdir -p "$FONT_DIR"
        cp "$tmpdir"/0xProto*.ttf "$FONT_DIR/"
        fc-cache -f >/dev/null
        echo "       Installed 0xProto Nerd Font to $FONT_DIR"
        echo "       Remember to select '0xProto Nerd Font Mono' in your terminal's"
        echo "       font settings (e.g. GNOME Terminal: Preferences → Profiles → Text)."
    fi
fi

echo "[6/9] Setting default shell to zsh..."
if [[ "$SHELL" != *zsh* ]]; then
    chsh -s "$(command -v zsh)"
fi

echo "[7/9] Installing fcitx5 (Chinese input, 微软双拼) and xsel (tmux clipboard)..."
if ! command -v fcitx5 >/dev/null 2>&1; then
    sudo apt-get install -y fcitx5 fcitx5-chinese-addons fcitx5-config-qt \
        fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 im-config
fi
# xsel: tmux copy-mode 'y' pipes the selection to the X11 clipboard
command -v xsel >/dev/null 2>&1 || sudo apt-get install -y xsel
# Activate fcitx5 as the input method framework (writes ~/.xinputrc); idempotent.
im-config -n fcitx5

echo "[8/9] Installing tmux + TPM (Tmux Plugin Manager)..."
command -v tmux >/dev/null 2>&1 || sudo apt-get install -y tmux
# TPM: clone if missing. Then inside tmux press <prefix> + I to install plugins (e.g. tmux-sensible).
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

echo "[9/9] Done! Log out and back in (needed for the default shell + fcitx5). Start/restart tmux, then press <prefix> + I to load plugins."
