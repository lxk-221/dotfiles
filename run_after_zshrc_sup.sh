#!/bin/bash
# run_after_zshrc_sup.sh
#
# 每次 chezmoi apply 都会执行(run_after_ 前缀保证在所有文件写入完成后才跑,
# 且无 once_/onchange_ 修饰,所以每次必跑)。
#
# 作用:在 chezmoi 管理的静态 ~/.zshrc 末尾 marker 之下,根据本机实际安装情况,
# 动态追加各工具的初始化配置。chezmoi apply 会先用 dot_zshrc 覆盖 ~/.zshrc
# (抹掉上次的动态部分),本脚本随后重新追加,因此天然幂等。
#
# 追加策略:
#   - 工具自带 init/setup 命令(conda、pnpm)→ 优先用官方命令,路径用绝对路径探测
#     (因为 run_* 脚本是独立进程,不继承 run_once 安装脚本里的 export PATH)。
#   - 工具无 init 机制(go、pixi)→ 直接 echo 一行 PATH。
#
# 阅读时:~/.zshrc 中 "===== 以上为 chezmoi 静态管理 =====" 标记以下的所有内容,
# 均由本脚本生成,请勿手动编辑(改动会在下次 chezmoi apply 时被覆盖)。

ZSHRC="$HOME/.zshrc"

# ---------- conda ----------
# 探测 miniconda / anaconda3 的常见安装位置(home 下或 /opt 下),
# 命中则调用官方 `conda init zsh`,它会在 zshrc 中追加/替换
# "# >>> conda initialize >>>" 块(自带幂等)。
CONDA_BIN=""
for p in \
    "$HOME/miniconda3/bin/conda" \
    "$HOME/anaconda3/bin/conda" \
    "/opt/miniconda3/bin/conda" \
    "/opt/anaconda3/bin/conda" \
    "/opt/homebrew/anaconda3/bin/conda"; do
    [ -x "$p" ] && CONDA_BIN="$p" && break
done
if [ -n "$CONDA_BIN" ]; then
    echo "[run_after_zshrc_sup] conda found at $CONDA_BIN, running 'conda init zsh'"
    "$CONDA_BIN" init zsh
else
    echo "[run_after_zshrc_sup] conda not found, skipping"
fi

# ---------- pnpm ----------
# 用 pnpm 自带的 `pnpm setup`:它设置 PNPM_HOME 并把对应 PATH 写入 shell rc。
# 在不同平台 PNPM_HOME 路径不同(macOS: ~/Library/pnpm; Linux: ~/.local/share/pnpm),
# 交给 setup 处理比手写更稳。用绝对路径探测,理由同 conda。
PNPM_BIN=""
for p in \
    "/opt/homebrew/bin/pnpm" \
    "/usr/local/bin/pnpm" \
    "$HOME/.local/share/pnpm/pnpm" \
    "$HOME/Library/pnpm/pnpm"; do
    [ -x "$p" ] && PNPM_BIN="$p" && break
done
# 兜底:如果 pnpm 已在当前 PATH(比如本次 apply 前就已配好),也接受。
[ -z "$PNPM_BIN" ] && command -v pnpm >/dev/null 2>&1 && PNPM_BIN="$(command -v pnpm)"
if [ -n "$PNPM_BIN" ]; then
    echo "[run_after_zshrc_sup] pnpm found at $PNPM_BIN, running 'pnpm setup'"
    "$PNPM_BIN" setup
else
    echo "[run_after_zshrc_sup] pnpm not found, skipping"
fi

# ---------- go ----------
# Go 没有 init/setup 机制,bin 路径标准化(/usr/local/go/bin),目录探测后 echo。
if [ -d /usr/local/go/bin ]; then
    echo "[run_after_zshrc_sup] go found at /usr/local/go/bin"
    echo '' >> "$ZSHRC"
    echo '# go' >> "$ZSHRC"
    echo 'export PATH="$PATH:/usr/local/go/bin"' >> "$ZSHRC"
fi

# ---------- pixi ----------
# pixi 官方 curl 安装脚本会自己改 rc,但我们不依赖它,改用目录探测 + 手动 echo,
# 避免和本脚本职责重叠。
if [ -d "$HOME/.pixi/bin" ]; then
    echo "[run_after_zshrc_sup] pixi found at $HOME/.pixi/bin"
    echo '' >> "$ZSHRC"
    echo '# pixi' >> "$ZSHRC"
    echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> "$ZSHRC"
fi
