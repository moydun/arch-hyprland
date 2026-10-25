# arch-hyprland

A purple "glass" Hyprland rice for Arch Linux: Hyprland's Lua config
(`hyprland.lua`, Hyprland ≥ 0.56), floating Waybar islands, Wofi, Kitty,
Fastfetch, Waypaper + awww, themed dunst, and hyprlock/hypridle.

Everything needed to rebuild it on a fresh Arch install lives in this repo:
configs, wallpaper, package lists, a theme helper and an installer.

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

Rounded 12px corners, soft shadows, blurred glass surfaces, 6/14 gaps and a
floating bar split into three islands. The old CRT scanline shader is kept in
the repo but disabled — see [Notes](#notes).

## What's inside

| Tracked path | Installs to | What it is |
| --- | --- | --- |
| `dotfiles/.bashrc` | `~/.bashrc` | purple prompt, `ls` alias, fastfetch, `~/.bashrc.local` hook |
| `dotfiles/.config/hypr/` | `~/.config/hypr/` | `hyprland.lua`, `hyprlock.conf`, `hypridle.conf`, `shaders/crt.frag` |
| `dotfiles/.config/waybar/` | `~/.config/waybar/` | `config.jsonc`, `style.css` |
| `dotfiles/.config/wofi/` | `~/.config/wofi/` | `style.css` |
| `dotfiles/.config/kitty/` | `~/.config/kitty/` | `kitty.conf` |
| `dotfiles/.config/fastfetch/` | `~/.config/fastfetch/` | `config.jsonc`, `logo.txt` |
| `dotfiles/.config/waypaper/` | `~/.config/waypaper/` | `config.ini`, `style.css`, `keybindings.ini` |
| `dotfiles/.config/dunst/` | `~/.config/dunst/` | themed `dunstrc` |
| `wallpapers/desktop-background.jpg` | `~/Pictures/wallpapers/` | the wallpaper (1920×1080) |
| `scripts/apply-theme.sh` | — | applies GTK / icon / cursor / Qt theme |
| `packages/` | — | `official.txt` (pacman) + `aur.txt` (yay/paru) |
| `install.sh` | — | installer |

## Requirements

- Arch Linux, Wayland session.
- **Hyprland ≥ 0.56** — this rice uses the Lua config API (`hl.*`), not
  `hyprland.conf`.
- `JetBrainsMono Nerd Font` for the UI, `Terminess Nerd Font Mono` if you want
  the retro terminal look.
- An AUR helper (`yay` or `paru`) for `waypaper`, `wlogout` and the themes.
- PipeWire + WirePlumber (volume keys use `wpctl`).

## Install on a fresh machine

```bash
git clone git@github.com:moydun/arch-hyprland.git ~/arch-hyprland
cd ~/arch-hyprland
./install.sh --packages --theme
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
| `--theme` | apply GTK/icons/cursor/Qt theme (`scripts/apply-theme.sh`) |
| `-n`, `--dry-run` | show what would happen, change nothing |
| `-t DIR`, `--target DIR` | install into `DIR` instead of `$HOME` |
| `-h`, `--help` | usage |

Notes:

- Only the app directories listed above are touched — never all of `~/.config`.
- Existing files are moved to `~/.dotfiles-backup-<timestamp>/`, never deleted.
- Default symlink mode keeps the repo as the source of truth. `--copy` gives a
  standalone setup.
- Re-running the installer is safe: its own symlinks are replaced in place.

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
| `SUPER + L` | lock (`hyprlock`) |
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
| `PRINT` | screenshot to `~/Pictures/Screenshots/` |
| `SUPER + SHIFT + 4` | region screenshot to clipboard |
| `SUPER + SHIFT + V` | clipboard history (cliphist + wofi) |
| `F9` / `F10` | brightness down / up |
| `XF86*` | volume, mute, mic mute, brightness, playerctl |

Keyboard layout is `us,ru` with `grp:alt_shift_toggle`.

## How the rice starts

`hyprland.lua` autostarts `waybar`, `dunst`, `awww-daemon`, the cliphist
watcher, `hypridle`, then `sleep 1 && waypaper --restore`, which re-applies the
wallpaper stored in `waypaper/config.ini`.

## Notes

- The display runs at **scale 1.0** for pixel-crisp UI. If text feels too
  small, edit the `hl.monitor` block to `1.25` (or `1.33`) — everything else
  scales with it.
- The wallpaper is the original art upscaled to 1920×1080. If you find a true
  high-res source, drop it in `wallpapers/desktop-background.jpg`.
- The CRT scanline shader is disabled. To bring it back, add to `decoration`:
  `screen_shader = os.getenv("HOME") .. "/.config/hypr/shaders/crt.frag"`.
- Waypaper persists the current wallpaper back into `config.ini`. In symlink
  mode that shows up as a git change — use `--copy` if that bothers you.
- The GTK/Qt theme is applied by `scripts/apply-theme.sh`, which auto-detects
  the installed Catppuccin / Papirus / Bibata variants.
- Dunst uses the themed `dunstrc` (rounded, purple frame, JetBrainsMono).
- `hyprlock` blurs the wallpaper; `hypridle` locks after 5 min and turns the
  panel off after 10.

## Secrets

Nothing sensitive is tracked and nothing sensitive should ever be added:
SSH keys, the n8n API env file, browser profiles, pgAdmin data and shell
history stay out of the repo. Machine-specific shell config belongs in
`~/.bashrc.local`, which `.bashrc` sources if present and which git ignores.