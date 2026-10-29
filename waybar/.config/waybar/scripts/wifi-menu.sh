#!/usr/bin/env bash
# Minimal Wi-Fi picker: nmcli + fuzzel
set -uo pipefail

nmcli radio wifi | grep -q enabled || nmcli radio wifi on

list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan auto 2>/dev/null |
    sort -t: -k1,1r |
    awk -F: '
        NF >= 4 {
            inuse = ($1 == "*") ? "✓ " : "  "
            signal = $(NF - 1)
            ssid = ""
            for (i = 2; i <= NF - 2; i++)
                ssid = ssid (i > 2 ? ":" : "") $i
            if (ssid == "" || seen[ssid]++)
                next
            printf "%s%s  ·  %s%%\t%s\n", inuse, ssid, signal, ssid
        }')

[ -z "$list" ] && exit 0

choice=$(printf '%s\n' "$list" | cut -f1 |
    fuzzel --dmenu --prompt "Wi-Fi  " --lines 10 --width 34) || exit 0
[ -z "$choice" ] && exit 0

ssid=$(printf '%s\n' "$list" | awk -F'\t' -v c="$choice" '$1 == c { print $2; exit }')
[ -z "$ssid" ] && exit 0

# Works for open and already-saved networks.
if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
    exit 0
fi

password=$(fuzzel --prompt-only "Password for $ssid  " --password) || exit 0
[ -z "$password" ] && exit 0
nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1
