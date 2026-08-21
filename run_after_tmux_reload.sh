#!/bin/sh
# TPM/plugins are pre-cloned by the run_once install scripts; tpm only loads
# when tmux (re)reads .tmux.conf, so reload any running server after apply.
if tmux info >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null \
        && echo "tmux: reloaded ~/.tmux.conf (tpm re-sourced)"
fi
