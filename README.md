## First Use
```
# install chezmoi
sh -c "$(curl -fsSL https://get.chezmoi.io)" 

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
- Mac: iTerm2 → Settings (Cmd+,) → Profiles → Text → Font
- Linux: Preferences → Profiles → Text → Custom Font
- vscode/cursor: Preference -> Font Family -> Termial 
