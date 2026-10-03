#!/usr/bin/env bash
# Link the widget's files into the Omarchy config, so the shell loads the
# versions in this repo and picks up edits on save.
#
# Safe to re-run. An existing real file is moved aside to <name>.bak rather
# than overwritten.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/bar"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    echo "ok      $dst"
    return
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "backed up $dst -> $dst.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "linked  $dst -> $src"
}

link "$REPO/bar/scripts/deepseek-balance"   "$CONFIG/scripts/deepseek-balance"
link "$REPO/bar/modules/deepseek-balance.qml" "$CONFIG/modules/deepseek-balance.qml"

cat <<'EOF'

Next: make sure the bar has the module. Add this to the right section of
~/.config/omarchy/shell.json (it hot-reloads on save):

  {
    "id": "deepseek-balance",
    "type": "qml",
    "interval": 1800,
    "onClick": "xdg-open https://platform.deepseek.com/usage"
  }

Then set the API key (mode 600, never committed):

  install -m 600 /dev/null ~/.config/omarchy/bar/deepseek-key
  printf '%s' 'sk-...' > ~/.config/omarchy/bar/deepseek-key

Restart the shell to pick up the QML: omarchy restart shell
EOF
