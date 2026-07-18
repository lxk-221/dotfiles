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
```
- sourceVCS: auto commit and push. No tool-specific variables needed anymore.

## zshrc 架构:静态 + 动态(marker 分界)

`~/.zshrc` 分两部分,以一行 marker 分界:

```
# ===== 以上为 chezmoi 静态管理;以下由 run_after_zshrc_sup.sh 在每次 chezmoi apply 时自动生成 =====
```

- **marker 以上** — 由 chezmoi 直接管理(`dot_zshrc`,纯静态文件,不再是 `.tmpl`):PATH、proxy、oh-my-zsh、starship、alias、tarzip 等。编辑这部分用 `chezmoi edit ~/.zshrc`。
- **marker 以下** — 由 `run_after_zshrc_sup.sh` 在**每次 `chezmoi apply`** 时探测本机已安装的工具并动态追加:conda(调官方 `conda init zsh`)、pnpm(调官方 `pnpm setup`)、go/pixi(目录探测 + echo PATH)。新装/卸载工具后,下次 apply 自动增删对应配置。

**为什么这样设计:** chezmoi apply 用静态 `dot_zshrc` 覆盖目标文件,天然抹掉上次的动态部分;`run_after_` 前缀保证脚本在文件覆盖之后才执行,追加始终从 marker 下方空白开始,因此天然幂等。这避免了"用 chezmoi toml 变量控制工具配置"的耦合——每台机器零配置,工具配置随装随有。

**注意 `chezmoi diff` 的噪音:** 由于 chezmoi 管理的目标状态是 `[静态 + marker]`,而 apply 后实际文件多了动态部分,所以 `chezmoi diff` 会显示"即将删除 marker 以下的行"——这是预期行为,apply 会重新生成,无害。

## Download Font for starship
### Download Font
[nerdfont](https://www.nerdfonts.com/font-downloads)
### Set Font
> Mono means the font has equal width, which is suitable to be used in terminal
- Mac: iTerm2 → Settings (Cmd+,) → Profiles → Text → Font → Select '0xProto Nerd Font Mono'
- Linux: Terminal → Preferences → Profiles → Text → Custom Font → Select '0xProto Nerd Font Mono'
- vscode/cursor: Preference -> Font Family -> Termial  # '0xProto Nerd Font Mono'
- ZCode Terminal: For local termnial, set font in "setting"; For remote terminal ZCode will detect code setting for font set, so a easy way is to run the command below
```shell
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json <<'EOF'
{
  "terminal.integrated.fontFamily": "'0xProto Nerd Font Mono'"
}
EOF
```
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

## Dynamic zshrc Supplement
`run_after_zshrc_sup.sh` (no `once_`/`onchange_` modifier → **runs on every `chezmoi apply**`, with the `run_after_` prefix guaranteeing it executes after all file targets are written) appends tool-specific configuration below the marker in `~/.zshrc`:

- **conda** — probes common miniconda/anaconda3 locations (`$HOME` or `/opt`), runs `conda init zsh` if found (uses the tool's own init, no path hardcoded in dotfiles).
- **pnpm** — probes common pnpm paths + falls back to `command -v`, runs `pnpm setup` if found.
- **go** — directory probe on `/usr/local/go/bin`, echoes a PATH line (no init mechanism exists).
- **pixi** — directory probe on `$HOME/.pixi/bin`, echoes a PATH line.

Binary paths use absolute-path probing rather than `command -v` because `run_*` scripts run as independent processes that don't inherit PATH exports from the `run_once_` install scripts. The install scripts only install binaries; **no `xxx init`/`xxx setup` calls belong there anymore** — all runtime configuration lives in this `run_after` script.

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
