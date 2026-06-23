## First Use
```
# install chezmoi
sudo sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b /usr/local/bin

# first init
chezmoi init --apply https://github.com/lxk-221/dotfiles
chezmoi init --apply git@github.com:lxk-221/dotfiles.git   # 已配 SSH key 用这行：可以push
```

## Basic Usage
```
# update from github 
chezmoi update

# modify chezmoi template and update to github
# cd -> add -> commit -> push
chezmoi cd
chezmoi git add .
chezmoi git commit
chezmoi git push
```

## device-specific setting
```
vim  ~/.config/chezmoi/chezmoi.toml
```

```
[edit]
    command = "vim"

[sourceVCS]
    autoCommit = true
    autoPush = true

[data]
    conda_path = "/opt/homebrew/anaconda3"
```
- sourceVCS, only need to add, auto commit and push
- conda\_path, will be used in zshrc, need to fill with the device specific conda path

## Download Font for starship
### Download Font
[nerdfont](https://www.nerdfonts.com/font-downloads)
### Set Font
> Mono means the font has equal width, which is suitable to be used in terminal
- Mac: iTerm2 → Settings (Cmd+,) → Profiles → Text → Font → Select '0xProto Nerd Font Mono'
- Linux: Terminal → Preferences → Profiles → Text → Custom Font → Select '0xProto Nerd Font Mono'
- vscode/cursor: Preference -> Font Family -> Termial  # '0xProto Nerd Font Mono'
Remember to **Close All Vscode/Cursor windows** to enable the font change

## For a totally new machine
```shell
sudo apt install net-tools curl vim git tmux
```

## OS-specific Install Scripts
`run_once_*.sh` are guarded both in `.chezmoiignore` (per-OS) and inside the script itself, so only the matching one runs on a given machine:

- **Linux (apt)** — `run_once_lxk_install.sh`: zsh, oh-my-zsh, zsh plugins, autojump, starship, fcitx5 (Chinese input), xsel (X11 clipboard), tmux + TPM.
- **macOS (Homebrew)** — `run_once_lxk_install_darwin.sh`: Homebrew, oh-my-zsh, zsh plugins, autojump, starship, tmux + TPM. zsh is skipped (default shell on macOS), and so are fcitx5/xsel (macOS uses the built-in input method and `pbcopy` for the clipboard).

Each script is idempotent — safe to re-run via `chezmoi apply`.

## Chinese Input (fcitx5, Linux/Ubuntu)
On Linux/apt systems, `run_once_lxk_install.sh` installs [fcitx5](https://fcitx-im.org/) and sets it as the active input method framework automatically. The pinyin config (微软双拼 / Microsoft double pinyin) is managed at `dot_config/fcitx5/conf/pinyin.conf`.

After first install, **log out and back in** so fcitx5 takes over the keyboard (the `~/.xinputrc` written by `im-config` is read at X session start).

If GNOME's built-in IBus pinyin still interferes, drop the IBus source while keeping the keyboard layout:
```shell
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'cn')]"
```
Toggle Chinese/English with `Ctrl+Space`. To change the double-pinyin scheme, edit `ShuangpinProfile` in `pinyin.conf` (e.g. `MS`=微软, `Xiaohe`=小鹤, `Ziranma`=自然码) and reload with `fcitx5 -r -d`.

## Chinese Input (macOS)
macOS 的输入法走系统自带的「键盘 → 输入源」，无需 fcitx5。在「系统设置 → 键盘 → 文本输入 → 编辑」里添加「拼音 - 简体」，双拼方案在拼音输入法的偏好设置中选择（如「微软」双拼）。
