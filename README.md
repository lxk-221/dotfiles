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

[diff]
    command = "delta"

[sourceVCS]
    autoCommit = true
    autoPush = true
```
- sourceVCS: auto commit and push. No tool-specific variables needed anymore.
- diff: `chezmoi diff` 输出经 delta 渲染(delta 由 run_once 脚本安装)。

## zoxide(目录跳转,替代 autojump)
autojump 已停止维护(上游推荐迁移 zoxide)且为 Python 脚本;zoxide 是 Rust 预编译二进制,零运行时依赖。run_once 安装,zshrc 中 `zoxide init zsh` 接入(装好即生效,未装自动跳过)。每次 `cd` 自动学习。

| 命令 | 作用 |
|---|---|
| `z foo` | 跳到最匹配 foo 的目录(旧 `j foo` 的新写法) |
| `z foo bar` | 多关键词逐级缩小 |
| `zi foo` | 交互式选择(配 fzf 体验最佳) |
| `zoxide query foo` | 只看匹配排行,不跳转 |

旧数据迁移(每台用过 autojump 的机器跑一次):`zoxide import autojump`(v0.10+ 语法,自动探测默认 db 位置;macOS 在 `~/Library/autojump/`,Linux 在 `~/.local/share/autojump/`)。`j`/`ji` 已设为 `z`/`zi` 的 alias,新旧肌肉记忆并存(init 的 `--cmd` 只支持单一命令名,若想让 `j` 成为唯一命令名才用它)。

## Font for starship (0xProto Nerd Font)
starship 等 prompt 依赖 Nerd Font 的图标字形。

### 自动安装(无需手动下载)
`run_once_lxk_install*.sh` 会在首次 `chezmoi apply` 时自动下载并安装 **0xProto Nerd Font**(从 [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts) 的 latest release 下载同一份 zip,跨平台一致):

- **macOS** → 解压到 `~/Library/Fonts/`(系统即装即用,无需刷新缓存)
- **Linux 桌面**(`$DISPLAY` 非空)→ 解压到 `~/.local/share/fonts/` + `fc-cache -f`
- **Linux 服务器(无 `$DISPLAY`)** → 自动跳过。服务器不渲染字体,渲染发生在你本地终端(SSH 连接),所以服务器装字体无意义。

字体文件**不进 git 仓库**(二进制大文件不该进 git,且服务器不需要)。每次 apply 检测到 `0xProtoNerdFontMono-Regular.ttf` 不存在才下载,幂等。

### 手动设置终端字体(这一步仍需人工)
字体装好后,需要在终端里**选中**它才会生效。各终端的设置入口:
> `Mono` = 等宽(适合终端);`Propo` = 比例宽;`NerdFont`(无后缀)= 介于两者之间。终端用 `Mono`。

- **iTerm2**: Settings (Cmd+,) → Profiles → Text → Font → '0xProto Nerd Font Mono'
- **Linux Terminal**(GNOME Terminal 等): Preferences → Profiles → Text → Custom Font → '0xProto Nerd Font Mono'
- **VS Code / Cursor**: Preferences → Font Family → Terminal → `0xProto Nerd Font Mono`。或在远程机器跑:
```shell
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json <<'EOF'
{
  "terminal.integrated.fontFamily": "'0xProto Nerd Font Mono'"
}
EOF
```
  改完**关闭所有 VS Code / Cursor 窗口**才生效。
- **ZCode Terminal**: 本地终端在 setting 里设字体;远程终端 ZCode 会探测 Code 的字体设置,所以跑上面那段写 `settings.json` 即可。

**为什么字体配置不自动化:** 各终端的字体配置存储方式差异极大(iTerm2 的 plist、VS Code 的 JSON、GNOME Terminal 的 dconf…),且 macOS Terminal.app 的二进制 plist 几乎无法安全脚本化。自动化的收益(省一次点击)远小于引入的复杂度和脆弱性,因此保留为人工步骤。字体**下载安装**(真正的痛点)已自动化。

### SSH 会话自动降级为无字形提示符(共享服务器场景)
本地终端的字体自己可控;但 SSH 到共享服务器时,渲染提示符的是**连接者本机的终端**——同事往往没装 nerd font,nerd/powerline 字形会显示为乱码。zshrc 因此做了运行时判断:

- **本地终端**:默认 `~/.config/starship.toml`(gruvbox-rainbow,nerd 版)
- **SSH 会话**(`$SSH_CONNECTION` 非空):默认 `~/.config/starship-plain.toml`(官方 no-nerd-font 预设 + git_branch/docker_context 补丁,零特殊字形,颜色保留)
- `nerd` / `plain`:当前会话内即时切换——starship 每次渲染都重读 `STARSHIP_CONFIG`,下一个提示符即生效,无需重新 init
- 切换仅当前会话有效:共享账号下无法区分你和同事,per-login 是唯一正确粒度;同事分独立账号后,可删掉 zshrc 里的 SSH 默认降级


## tmux 双模板(共享服务器协作)
与 starship 的 SSH 降级同一场景:SSH 到共享服务器时,`prefix` 改键、vi copy-mode、鼠标、zsh 默认 shell 等会影响共用账号的同事。`~/.tmux.conf` 因此分两区:

- **通用区** — 纯增量的设置与按键(方向键分屏、`M-o` 新窗口、`prefix+hjkl` 移动窗格、`C-n/C-p` 切窗口等),不覆盖任何 tmux 默认行为,对任何人安全
- **模板区** — 破坏性 set/unset 拆成两个模板:`~/.config/tmux/xukun.conf`(个人配置)与 `~/.config/tmux/plain.conf`(逆操作,显式还原全部默认值)。注意 `default-shell` 在 Linux 上 plain 显式设为 `/bin/bash` 而非 unset——平台网关强制交互会话用 bash,且 tmux 动态解析链(server 启动 SHELL 快照 → passwd → /bin/sh)在注入过 sh-wrap 的共享平台上不可靠,写死才能确定还原"直连 bash"的协作体验;macOS 则 unset 回落本机 zsh。

选择逻辑(`~/.config/tmux/is-xukun`):`~/.config/tmux/profile` 文件优先;无该文件时 SSH 会话默认 **plain**(原 prefix C-b),本地默认 **xukun**。

| 命令 | 作用 |
|---|---|
| `tmux-plain` | 切协作模板:原 prefix/默认键位,仅保留通用区增量按键 |
| `tmux-xukun` | 切个人模板:完整个人配置(prefix C-a 等) |

两个函数都会写 profile 文件并 `tmux source-file ~/.tmux.conf` 热重载(等价于 `run_after_tmux_reload.sh` 做的事)。与 starship 的关键差异:starship 渲染是 per-session 的(每个提示符独立读 `STARSHIP_CONFIG`),tmux 配置是 **server 级全局**——切换对本 server 所有 attached 客户端立即生效;且 profile 文件是**账号级**的,共享账号上切到 xukun 后,同事下次 SSH 也会读到 xukun,所以协作结束记得 `tmux-plain` 切回(或删掉 profile 文件恢复 SSH 自动判断)。

## For a totally new machine
```shell
sudo apt install net-tools curl vim git tmux
```

## OS-specific Install Scripts
`run_once_*.sh` are guarded both in `.chezmoiignore` (per-OS) and inside the script itself, so only the matching one runs on a given machine:

- **Linux (apt)** — `run_once_lxk_install_linux.sh`: zsh, oh-my-zsh, zsh plugins, zoxide, starship, delta, 0xProto Nerd Font (desktop only), fcitx5 (Chinese input), xsel (X11 clipboard), tmux + TPM + tmux plugins.
- **macOS (Homebrew)** — `run_once_lxk_install_darwin.sh`: Homebrew, oh-my-zsh, zsh plugins, zoxide, starship, delta, 0xProto Nerd Font, tmux + TPM + tmux plugins. zsh is skipped (default shell on macOS), and so are fcitx5/xsel (macOS uses the built-in input method and `pbcopy` for the clipboard).

Each script is idempotent — safe to re-run via `chezmoi apply`.

tmux 插件由脚本直接 git clone(与 zsh 插件同款模式),不依赖 TPM 的 `prefix + I`:apply 终端里可见进度、可 Ctrl-C 中断;tmux 启动时自动加载,TPM 仅保留 `prefix + U` 用于更新。

## Chinese Input (fcitx5, Linux/Ubuntu)
On Linux/apt systems, `run_once_lxk_install_linux.sh` installs [fcitx5](https://fcitx-im.org/) and sets it as the active input method framework automatically. The pinyin config (微软双拼 / Microsoft double pinyin) is managed at `dot_config/fcitx5/conf/pinyin.conf`.

After first install, **log out and back in** so fcitx5 takes over the keyboard (the `~/.xinputrc` written by `im-config` is read at X session start).

If GNOME's built-in IBus pinyin still interferes, drop the IBus source while keeping the keyboard layout:
```shell
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'cn')]"
```
Toggle Chinese/English with `Ctrl+Space`. To change the double-pinyin scheme, edit `ShuangpinProfile` in `pinyin.conf` (e.g. `MS`=微软, `Xiaohe`=小鹤, `Ziranma`=自然码) and reload with `fcitx5 -r -d`.

## Chinese Input (macOS)
macOS 的输入法走系统自带的「键盘 → 输入源」，无需 fcitx5。在「系统设置 → 键盘 → 文本输入 → 编辑」里添加「拼音 - 简体」，双拼方案在拼音输入法的偏好设置中选择（如「微软」双拼）。

---

# 设计理念

以下内容不是使用引导,而是解释这套 dotfiles 为什么这样组织。日常使用不需要读;想理解或改动架构时再来看。

## zshrc 架构:静态 + 动态(marker 分界)

`~/.zshrc` 分两部分,以一行 marker 分界:

```
# ===== 以上为 chezmoi 静态管理;以下由 run_after_zshrc_sup.sh 在每次 chezmoi apply 时自动生成 =====
```

- **marker 以上** — 由 chezmoi 直接管理(`dot_zshrc`,纯静态文件,不再是 `.tmpl`):PATH、proxy、oh-my-zsh、starship、alias、tarzip 等。编辑这部分用 `chezmoi edit ~/.zshrc`。
- **marker 以下** — 由 `run_after_zshrc_sup.sh` 在**每次 `chezmoi apply`** 时探测本机已安装的工具并动态追加:conda(调官方 `conda init zsh`)、pnpm(调官方 `pnpm setup`)、go/pixi/cargo(目录探测 + echo PATH)。新装/卸载工具后,下次 apply 自动增删对应配置。

**为什么这样设计:** chezmoi apply 用静态 `dot_zshrc` 覆盖目标文件,天然抹掉上次的动态部分;`run_after_` 前缀保证脚本在文件覆盖之后才执行,追加始终从 marker 下方空白开始,因此天然幂等。这避免了"用 chezmoi toml 变量控制工具配置"的耦合——每台机器零配置,工具配置随装随有。

**注意 `chezmoi diff` 的噪音:** 由于 chezmoi 管理的目标状态是 `[静态 + marker]`,而 apply 后实际文件多了动态部分,所以 `chezmoi diff` 会显示"即将删除 marker 以下的行"——这是预期行为,apply 会重新生成,无害。同理,**每次交互式 `chezmoi apply` 会询问一次** ".zshrc has changed since chezmoi last wrote it"(run_after 的追加让 live 文件永远不等于 chezmoi 记录的上次写入内容)——按 `y` 确认即可;脚本/非交互场景用 `chezmoi apply --force`。这是该架构的固定成本。

## 三类脚本的职责划分

| 脚本 | 何时跑 | 职责 |
|---|---|---|
| `run_once_lxk_install*.sh` | 内容 hash 变化时跑一次 | **只装"通用基础"**:zsh、oh-my-zsh、zsh 插件、starship、tmux、tpm、tmux 插件、zoxide(Linux 还有 fcitx5、xsel)。不跑任何 `xxx init`/`xxx setup` |
| `dot_zshrc` | 每次 apply 覆盖目标 | **静态配置**(oh-my-zsh、proxy、starship init、函数、alias) |
| `run_after_zshrc_sup.sh` | **每次 apply** 都跑(`run_after_` 前缀保证在文件写入后执行) | **动态配置**:探测 conda/pnpm/go/pixi/cargo,有 init 的调官方 init,没有的 echo PATH,全部追加到 marker 以下 |

**关键设计点:** 安装脚本和配置脚本彻底分离。`run_once_` 只负责"把二进制装上",`run_after_` 只负责"把配置写进 zshrc"。这样安装时不会污染 rc,配置时不会重复安装。

## 工具分层:基础工具 vs. 额外工具

这是这套 dotfiles 最重要的边界判断,决定一个工具该由谁负责安装。

| 类别 | 例子 | 谁负责安装 | 配置怎么进 zshrc |
|---|---|---|---|
| **基础工具**(通用 CLI / 环境骨架) | zsh、oh-my-zsh、tmux、tpm、starship、zoxide | `run_once_` 安装脚本 | starship/zoxide 走 `dot_zshrc` 里的静态 `command -v` 守卫;其余通过自身机制,不单独配 |
| **额外工具**(项目/语言/包管理器) | conda、pnpm、pixi、go、cargo | **用户自己装** | `run_after_zshrc_sup.sh` 探测到就自动写配置 |

**为什么这样分:**

- **基础工具是"装了 dotfiles 就该有"的标配**——没有 zsh/oh-my-zsh/starship 这套 zshrc 根本跑不起来,所以由 run_once 兜底,新机器 apply 一次就齐活。
- **额外工具是"看项目需要才装"的可选项**——一台机器可能装 conda 不装 pnpm,另一台可能装 pixi 不装 conda。把它们塞进 run_once 会带来重复安装的探测难题(见下)、也违背"chezmoi 只管通用配置同步"的克制原则。让用户按需自装,run_after 负责发现,最干净。

**为什么不把 conda/pnpm 也放进 run_once(以及为什么不需要 run_before 预处理):**

一个看起来诱人但有坑的思路是"run_once 里用 `command -v conda` 探测,没有就装"。问题在于 `run_*` 脚本是被 chezmoi 拉起的**独立进程,不继承**其他进程的 `export PATH`。全新机器首次 apply 时,即便 conda 已存在(比如用户手动装过),只要它不在 chezmoi 进程的默认 PATH 里,`command -v conda` 就返回空 → run_once 误判"未装" → **重复下载安装**。

正确的解法不是"再加个 run_before 把 zshrc 里的路径提取到临时文件喂给 run_once"(那样引入解析 zshrc 文本 + 进程间状态传递的双重耦合,过度设计),而是**根本不让 run_once 碰这类工具**。额外工具交给用户自装,run_after 用绝对路径 `[ -x ]`/`[ -d ]` 探测文件系统(文件系统是持久状态,不依赖 PATH),这条链路天然没有重复安装问题,也不需要任何跨脚本的状态传递。

> 一句话总结:基础工具归 run_once 装死、额外工具归用户装活、run_after 只读不写安装。
