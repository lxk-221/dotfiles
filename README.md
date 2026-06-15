## First Use
```
# install chezmoi
sudo sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b /usr/local/bin

# first init
chezmoi init --apply https://github.com/lxk-221/dotfiles
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
