#!/bin/bash
# Removes the Tang Poem Screensaver and restores Omarchy's own screensaver.
# The AR PL UKai font is left installed; remove it with: omarchy pkg remove ttf-arphic-ukai
set -euo pipefail

dir="$HOME/.config/omarchy/screensaver"
branding="$HOME/.config/omarchy/branding"
profile="$HOME/.bash_profile"

pkill -f '/tang-screensaver$' 2>/dev/null || true

if [[ -f "$profile" ]]; then
  sed -i '/^# >>> tang-poem-screensaver >>>$/,/^# <<< tang-poem-screensaver <<<$/d' "$profile"
fi

rm -f "$dir/tang-screensaver" "$dir/omarchy-launch-screensaver" "$dir/tang-screensaver-uninstall" "$dir/tang-poems.txt" "$dir/foot.ini"
rmdir "$dir" 2>/dev/null || true

if [[ -f "$branding/screensaver.txt.before-tang" ]]; then
  mv "$branding/screensaver.txt.before-tang" "$branding/screensaver.txt"
elif [[ -f "${OMARCHY_PATH:-/usr/share/omarchy}/logo.txt" ]]; then
  cp "${OMARCHY_PATH:-/usr/share/omarchy}/logo.txt" "$branding/screensaver.txt"
fi

echo "Removed. Omarchy's own screensaver is back."
