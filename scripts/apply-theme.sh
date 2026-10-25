#!/usr/bin/env bash
#
# Apply the rice's GTK / icon / cursor / Qt look.
# Safe to re-run. Detects whatever theme variants are actually installed.
#
set -euo pipefail

say() { printf '%s\n' "$*"; }

# --- GTK theme: prefer a Catppuccin Mocha build, else any Catppuccin ---
theme=""
for d in /usr/share/themes/*/; do
    b="$(basename "$d")"
    case "$b" in
        *[Cc]atppuccin*[Mm]ocha*) theme="$b"; break ;;
    esac
done
if [[ -z "$theme" ]]; then
    for d in /usr/share/themes/*/; do
        b="$(basename "$d")"
        case "$b" in *[Cc]atppuccin*) theme="$b"; break ;; esac
    done
fi

# --- icons ---
icons=""
for c in Papirus-Dark Papirus; do
    if [[ -d "/usr/share/icons/$c" ]]; then icons="$c"; break; fi
done

# --- cursor ---
cursor=""
for d in /usr/share/icons/Bibata*; do
    [[ -d "$d" ]] || continue
    cursor="$(basename "$d")"
    case "$cursor" in *Modern*Ice*) break ;; esac
done

if command -v gsettings >/dev/null 2>&1; then
    [[ -n "$theme"  ]] && gsettings set org.gnome.desktop.interface gtk-theme "$theme"
    [[ -n "$icons"  ]] && gsettings set org.gnome.desktop.interface icon-theme "$icons"
    [[ -n "$cursor" ]] && gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

    if fc-match "Inter" 2>/dev/null | grep -qi 'Inter'; then
        gsettings set org.gnome.desktop.interface font-name "Inter 10"
    fi
    if fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -qi 'JetBrains'; then
        gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 11"
    fi
fi

# --- GTK4 (libadwaita apps): link the theme's gtk-4.0 overrides ---
if [[ -n "$theme" && -d "/usr/share/themes/$theme/gtk-4.0" ]]; then
    mkdir -p "$HOME/.config/gtk-4.0"
    for f in gtk.css gtk-dark.css assets; do
        if [[ -e "/usr/share/themes/$theme/gtk-4.0/$f" ]]; then
            ln -sfn "/usr/share/themes/$theme/gtk-4.0/$f" "$HOME/.config/gtk-4.0/$f"
        fi
    done
fi

# --- Qt (Dolphin etc.): keep qt6ct, but match the icon set ---
qt_conf="$HOME/.config/qt6ct/qt6ct.conf"
if [[ -f "$qt_conf" && -n "$icons" ]]; then
    cp -n "$qt_conf" "$qt_conf.bak" 2>/dev/null || true
    sed -i "s/^icon_theme=.*/icon_theme=$icons/" "$qt_conf"
fi

say "theme:  ${theme:-<none found>}"
say "icons:  ${icons:-<none found>}"
say "cursor: ${cursor:-<none found>}"
say "qt:     ${qt_conf}"
say ""
say "Log out/in (or restart apps) for all toolkits to pick this up."