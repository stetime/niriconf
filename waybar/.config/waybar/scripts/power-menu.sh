#!/usr/bin/env bash
# Minimal session menu: fuzzel + loginctl/systemctl/niri
set -uo pipefail

choice=$(printf '%s\n' "Lock" "Log out" "Suspend" "Reboot" "Shutdown" |
    fuzzel --dmenu --prompt "Power  " --lines 5 --width 20) || exit 0

case "$choice" in
    Lock)     swaylock -f -c 1a1b26 ;;
    "Log out") niri msg action quit --skip-confirmation ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
