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

## Chinese Input (fcitx5, Linux/Ubuntu)
On Linux/apt systems, `run_once_lxk_install.sh` installs [fcitx5](https://fcitx-im.org/) and sets it as the active input method framework automatically. The pinyin config (微软双拼 / Microsoft double pinyin) is managed at `dot_config/fcitx5/conf/pinyin.conf`.

After first install, **log out and back in** so fcitx5 takes over the keyboard (the `~/.xinputrc` written by `im-config` is read at X session start).

If GNOME's built-in IBus pinyin still interferes, drop the IBus source while keeping the keyboard layout:
```shell
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'cn')]"
```
Toggle Chinese/English with `Ctrl+Space`. To change the double-pinyin scheme, edit `ShuangpinProfile` in `pinyin.conf` (e.g. `MS`=微软, `Xiaohe`=小鹤, `Ziranma`=自然码) and reload with `fcitx5 -r -d`.
