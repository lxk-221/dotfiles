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
chezmoi add .
chezmoi commit
chezmoi push
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
