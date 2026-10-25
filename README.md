# arch-hyprland

A small purple / retro-CRT Hyprland rice for Arch Linux, built around Hyprland's
Lua config (`hyprland.lua`, Hyprland ≥ 0.56), Waybar, Wofi, Kitty, Fastfetch,
Waypaper + awww, and dunst.

Everything needed to rebuild it on a fresh Arch install lives in this repo:
configs, wallpaper, package lists, and an installer.

## Palette

| Role | Hex |
| --- | --- |
| background | `#0b0612` |
| background alt | `#170d24` |
| foreground | `#e0d0ff` |
| primary purple | `#a855f7` |
| bright purple | `#c084fc` |
| dim purple | `#6b3fa0` |
| phosphor green (accents only) | `#7cffb2` |
| warning pink | `#ff5c8a` |

Flat borders, no rounding, no shadows, no blur, snappy animations, and a CRT
scanline shader.

## What's inside

| Tracked path | Installs to | What it is |
| --- | --- | --- |
| `dotfiles/.bashrc` | `~/.bashrc` | purple prompt, `ls` alias, fastfetch, `~/.bashrc.local` hook |
| `dotfiles/.config/hypr/` | `~/.config/hypr/` | `hyprland.lua`, `shaders/crt.frag` |
| `dotfiles/.config/waybar/` | `~/.config/waybar/` | `config.jsonc`, `style.css` |
| `dotfiles/.config/wofi/` | `~/.config/wofi/` | `style.css` |
| `dotfiles/.config/kitty/` | `~/.config/kitty/` | `kitty.conf` |
| `dotfiles/.config/fastfetch/` | `~/.config/fastfetch/` | `config.jsonc`, `logo.txt` |
| `dotfiles/.config/waypaper/` | `~/.config/waypaper/` | `config.ini`, `style.css`, `keybindings.ini` |
| `wallpapers/desktop-background.jpg` | `~/Pictures/wallpapers/` | the wallpaper |
| `packages/` | — | `official.txt` (pacman) + `aur.txt` (yay/paru) |
| `install.sh` | — | installer |

## Requirements

- Arch Linux, Wayland session.
- **Hyprland ≥ 0.56** — this rice uses the Lua config API (`hl.*`), not
  `hyprland.conf`.
- `Terminess Nerd Font Mono` (package `ttf-terminus-nerd`).
- An AUR helper (`yay` or `paru`) for `waypaper`.
- Audio via PipeWire + WirePlumber (the volume keys use `wpctl`).

## Install on a fresh machine

```bash
git clone git@github.com:moydun/arch-hyprland.git ~/arch-hyprland
cd ~/arch-hyprland
./install.sh --packages
```

Then log out and back in (or start Hyprland). If it is already running:

```bash
hyprctl reload
pkill -SIGUSR2 waybar
```

### Installer options

| Flag | Meaning |
| --- | --- |
| `-l`, `--link` | symlink configs into `$HOME` (default) |
| `-c`, `--copy` | copy configs instead of symlinking |
| `-p`, `--packages` | install `packages/official.txt` and `packages/aur.txt` |
| `-n`, `--dry-run` | show what would happen, change nothing |
| `-t DIR`, `--target DIR` | install into `DIR` instead of `$HOME` |
| `-h`, `--help` | usage |

Notes:

- Only the app directories listed above are touched — never all of `~/.config`.
- Existing files are moved to `~/.dotfiles-backup-<timestamp>/`, never deleted.
- Default symlink mode keeps the repo as the source of truth: editing a config
  and committing is one workflow. `--copy` gives a standalone setup.
- Re-running the installer is safe: its own symlinks are replaced in place.

### Manual install

```bash
sudo pacman -S --needed $(grep -vE '^#|^$' packages/official.txt)
yay -S --needed waypaper
cp -a dotfiles/.bashrc ~/
cp -a dotfiles/.config/hypr dotfiles/.config/waybar dotfiles/.config/wofi \
      dotfiles/.config/kitty dotfiles/.config/fastfetch dotfiles/.config/waypaper ~/.config/
mkdir -p ~/Pictures/wallpapers
cp wallpapers/desktop-background.jpg ~/Pictures/wallpapers/
```

## Keybindings

`SUPER` is the main modifier.

| Binding | Action |
| --- | --- |
| `SUPER + Q` | kitty |
| `SUPER + C` | close window |
| `SUPER + M` | exit Hyprland (`hyprshutdown` if present, else `loginctl`) |
| `SUPER + E` | dolphin |
| `SUPER + R` | wofi launcher |
| `SUPER + D` | toggle wofi |
| `SUPER + V` | toggle floating |
| `SUPER + P` | pseudo-tile |
| `SUPER + J` | toggle split (dwindle) |
| `SUPER + S` | scratchpad (`special:magic`) |
| `SUPER + SHIFT + S` | move window to scratchpad |
| `SUPER + 1…0` | switch workspace |
| `SUPER + SHIFT + 1…0` | move window to workspace |
| `SUPER + arrows` | move focus |
| `SUPER + LMB / RMB` | drag / resize window |
| `SUPER + scroll` | previous / next workspace |
| `F9` / `F10` | brightness down / up |
| `XF86*` | volume, mute, mic mute, brightness, playerctl |

Keyboard layout is `us,ru` with `grp:alt_shift_toggle`.

## How the rice starts

`hyprland.lua` autostarts `waybar`, `dunst`, `awww-daemon`, then
`sleep 1 && waypaper --restore`, which re-applies the wallpaper stored in
`waypaper/config.ini`.

## Notes

- The wallpaper is tracked (56 KB). Waypaper points at
  `~/Pictures/wallpapers/desktop-background.jpg`; the installer copies it there.
- Waypaper persists the current wallpaper back into `config.ini`. In symlink
  mode that shows up as a git change — use `--copy` if that bothers you.
- The CRT shader is enabled via `decoration.screen_shader`. Delete that line if
  you game on this machine.
- Monitor scale is `1.33`; adjust the `hl.monitor` block for your display.
- `hyprpaper` is not used and `hyprpaper.conf` was removed (there is an empty
  leftover in `~/.config/hypr/` on the original machine).
- Dunst runs with its default config — no custom `dunstrc` is tracked.

## Secrets

Nothing sensitive is tracked and nothing sensitive should ever be added:
SSH keys, the n8n API env file, browser profiles, pgAdmin data and shell
history stay out of the repo. Machine-specific shell config belongs in
`~/.bashrc.local`, which `.bashrc` sources if present and which git ignores.