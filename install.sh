#!/bin/bash
# Installs the Tang Poem Screensaver for Omarchy.
# Safe to run again: it updates an existing install in place.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/files"
dir="$HOME/.config/omarchy/screensaver"
branding="$HOME/.config/omarchy/branding"
profile="$HOME/.bash_profile"
marker="# >>> tang-poem-screensaver >>>"
end_marker="# <<< tang-poem-screensaver <<<"

if ! command -v omarchy-launch-screensaver >/dev/null; then
  echo "This needs Omarchy (https://omarchy.org): omarchy-launch-screensaver was not found." >&2
  exit 1
fi

echo "Installing the brush-style Chinese font (AR PL UKai)..."
if ! fc-list | grep -q "AR PL UKai"; then
  omarchy pkg add ttf-arphic-ukai
fi

echo "Copying the screensaver to $dir..."
mkdir -p "$dir"
install -m 755 "$src/tang-screensaver" "$src/omarchy-launch-screensaver" "$dir/"
install -m 644 "$src/tang-poems.txt" "$dir/"
install -m 755 "$src/../uninstall.sh" "$dir/tang-screensaver-uninstall"
# Keep a foot.ini the user has already adjusted (font or size), but move
# the old black background of earlier versions to the paper color.
if [[ -f "$dir/foot.ini" ]]; then
  sed -i 's/^background=000000$/background=fffcf0/; s/^foreground=ffffff$/foreground=100f0f/' "$dir/foot.ini"
else
  install -m 644 "$src/foot.ini" "$dir/"
fi

# Omarchy starts the screensaver from a login shell, so putting this folder
# first on PATH in ~/.bash_profile lets our launcher stand in for the stock one.
if ! grep -qF "$marker" "$profile" 2>/dev/null; then
  echo "Adding the screensaver folder to PATH in $profile..."
  if [[ ! -f "$profile" ]]; then
    # A new ~/.bash_profile stops bash from reading ~/.profile, so keep it read.
    if [[ -f "$HOME/.profile" ]]; then
      echo '[[ -f ~/.profile ]] && . ~/.profile' >"$profile"
    else
      echo '[[ -f ~/.bashrc ]] && . ~/.bashrc' >"$profile"
    fi
  fi
  printf '\n%s\nPATH="$HOME/.config/omarchy/screensaver:$PATH"\n%s\n' "$marker" "$end_marker" >>"$profile"
fi

# The stock screensaver still runs if it is started from an ordinary terminal.
# Give it a poem too instead of the Omarchy logo; uninstall.sh puts it back.
mkdir -p "$branding"
if [[ -f "$branding/screensaver.txt" && ! -f "$branding/screensaver.txt.before-tang" ]]; then
  cp "$branding/screensaver.txt" "$branding/screensaver.txt.before-tang"
fi
# Its text effects count every character as one column, so a zero-width space
# after each Chinese character keeps the lines centered.
python3 - "$branding/screensaver.txt" <<'EOF'
import sys
poem = ["靜 夜 思", "", "李 白", "", "床 前 明 月 光", "疑 是 地 上 霜", "舉 頭 望 明 月", "低 頭 思 故 鄉"]
text = "\n".join(poem) + "\n"
with open(sys.argv[1], "w", encoding="utf-8") as f:
    f.write("".join(c + "​" if ord(c) >= 0x2E80 else c for c in text))
EOF

echo
echo "Done. To see it now, run:"
echo "  bash -lc 'omarchy-launch-screensaver force'"
echo "It also starts on its own when your computer has been idle (set in ~/.config/omarchy/shell.json)."
echo "To remove it later, run: bash ~/.config/omarchy/screensaver/tang-screensaver-uninstall"
