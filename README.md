# Niri desktop dotfiles

Snapshot of the niri + Waybar setup (Fedora 44, niri 26.04, Waybar 0.15).

The directory uses the same per-app layout as `~/dotfiles`, so each app
directory can be merged into that repo as-is:

```
waybar/.config/waybar/            config.jsonc, style.css, scripts/
niri/.config/niri/config.kdl      full config (stock template + focus-ring tweak)
foot/.config/foot/foot.ini        font + CSD settings
fuzzel/.config/fuzzel/fuzzel.ini  dark launcher theme
environment/.config/environment.d/50-qt-dark.conf
```

## Changes made

### Waybar

- New minimalist Tokyo Night bar, 30 px high, top of screen.
- Left: Fedora launcher + numbered niri workspaces (accent underline on active).
- Centre: clock; hover shows a calendar.
- Right: tray, Wi-Fi, Bluetooth, volume, battery, power.
- Actions:
  - launcher -> `fuzzel`
  - network -> `scripts/wifi-menu.sh` (nmcli + fuzzel picker)
  - bluetooth -> `foot -e bluetoothctl`
  - volume -> click mutes, scroll adjusts
  - power -> `scripts/power-menu.sh` (lock / log out / suspend / reboot / shutdown)
- Font: `JetBrainsMono Nerd Font` (not included, see below).

### Fuzzel

- Dark theme that matches the bar, used by the launcher and the two menus.

### Foot

- Disabled foot's client-side titlebar. On niri it made every foot window
  about 18 px shorter than the available height, leaving a gap at the bottom.

```ini
[csd]
preferred=none
size=0
```

### Niri

Only the focus ring was changed in the otherwise stock config:

```kdl
focus-ring {
    width 3
    active-color "#7aa2f7"
}
```

(Was width 4 / `#7fc8ff`.)

### Qt apps

niri does not set the Qt platform theme, so KDE/Qt apps ignored the dark
`kdeglobals` and rendered light. `QT_QPA_PLATFORMTHEME=kde` fixes that.

`environment/.config/environment.d/50-qt-dark.conf`:

```ini
QT_QPA_PLATFORMTHEME=kde
```

Requires a re-login before niri-launched apps inherit it. GTK apps were
already dark through `gsettings` (`color-scheme=prefer-dark`) and Breeze.

## Dependencies

Present on this machine:

- `waybar`, `niri`, `foot`, `fuzzel`
- `NetworkManager` (`nmcli`) for the Wi-Fi menu
- `wireplumber` (`wpctl`) for volume
- `swaylock` for "Lock"
- `bluetooth` / `bluez` for the Bluetooth module

## Installing on another machine

Back up existing configs first, then symlink (or copy) the app directories:

```sh
ln -s ~/dotfiles-niri/waybar/.config/waybar       ~/.config/waybar
ln -s ~/dotfiles-niri/niri/.config/niri           ~/.config/niri
ln -s ~/dotfiles-niri/foot/.config/foot           ~/.config/foot
ln -s ~/dotfiles-niri/fuzzel/.config/fuzzel       ~/.config/fuzzel
mkdir -p ~/.config/environment.d
ln -s ~/dotfiles-niri/environment/.config/environment.d/50-qt-dark.conf \
  ~/.config/environment.d/50-qt-dark.conf
```

### Font

The bar uses JetBrainsMono Nerd Font. Only four weights are needed
(Regular, Medium, SemiBold, Bold):

```sh
curl -L -o /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
install -Dm644 /tmp/JetBrainsMono/JetBrainsMonoNerdFont-{Regular,Medium,SemiBold,Bold}.ttf \
  ~/.local/share/fonts/JetBrainsMonoNerd/
fc-cache -f
```

Alternatively, change `font-family` in `waybar/style.css`; `Cascadia Code NF`
(already used by foot) is also a Nerd Font.

## Applying changes

```sh
pkill -SIGUSR2 waybar            # reload bar config/style
niri msg action load-config-file # reload niri
```

Re-open existing foot windows after changing `foot.ini`; foot reads its config
on startup. Log out/in once for the Qt platform theme to apply everywhere.
