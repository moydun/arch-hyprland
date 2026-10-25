#!/usr/bin/env bash
#
# arch-hyprland installer
#
# Symlinks (or copies) the dotfiles in ./dotfiles into $HOME, installs the
# wallpaper, and optionally installs the package lists.
#
# Default is symlink mode so the repo stays the single source of truth:
# edit a config, commit, done. Use --copy for a fully standalone setup.
#
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SRC_DIR="$REPO_DIR/dotfiles"
TARGET="${HOME:-}"
MODE="link"
WITH_PACKAGES=0
DRY_RUN=0

BACKUP_DIR=""
BACKED_UP=0
MANAGED=()

die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Installs this rice's dotfiles into $HOME.

Options:
  -c, --copy         Copy files instead of symlinking them
  -l, --link         Symlink files (default)
  -p, --packages     Install packages/official.txt (pacman) and packages/aur.txt (yay/paru)
  -n, --dry-run      Print what would happen, change nothing
  -t, --target DIR   Install into DIR instead of $HOME (mostly for testing)
  -h, --help         Show this help

Examples:
  ./install.sh                  # symlink the configs
  ./install.sh --packages       # symlink configs + install packages
  ./install.sh --copy           # standalone copy, no symlinks
  ./install.sh -n               # dry run
EOF
}

run() {
  if (( DRY_RUN )); then
    printf '  [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

discover_managed() {
  local top sub
  while IFS= read -r top; do
    if [[ "$top" == ".config" ]]; then
      while IFS= read -r sub; do
        MANAGED+=(".config/$sub")
      done < <(find "$SRC_DIR/.config" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
    else
      MANAGED+=("$top")
    fi
  done < <(find "$SRC_DIR" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
}

backup_path() {
  local rel="$1"
  local dst="$TARGET/$rel"

  [[ -e "$dst" || -L "$dst" ]] || return 0

  # Re-running the installer: replace our own symlinks without backing them up.
  if [[ -L "$dst" ]]; then
    local resolved
    resolved="$(readlink -f -- "$dst" 2>/dev/null || true)"
    case "$resolved" in
      "$SRC_DIR"/*)
        run rm -f -- "$dst"
        return 0
        ;;
    esac
  fi

  if (( DRY_RUN )); then
    printf '  [dry-run] backup %s -> %s\n' "$rel" "$BACKUP_DIR/$rel"
    return 0
  fi

  mkdir -p -- "$BACKUP_DIR/$(dirname -- "$rel")"
  mv -- "$dst" "$BACKUP_DIR/$rel"
  BACKED_UP=1
}

install_one() {
  local rel="$1"
  local src="$SRC_DIR/$rel"
  local dst="$TARGET/$rel"

  [[ -e "$src" ]] || die "missing source file: $src"

  backup_path "$rel"
  run mkdir -p -- "$(dirname -- "$dst")"

  if [[ "$MODE" == "link" ]]; then
    run ln -sfn -- "$src" "$dst"
  else
    run cp -a -- "$src" "$dst"
  fi

  (( DRY_RUN )) || printf '  %-4s %s\n' "$MODE" "$rel"
}

install_wallpapers() {
  local src_dir="$REPO_DIR/wallpapers"
  local dst_dir="$TARGET/Pictures/wallpapers"
  [[ -d "$src_dir" ]] || return 0

  shopt -s nullglob
  local walls=("$src_dir"/*)
  shopt -u nullglob
  (( ${#walls[@]} )) || return 0

  run mkdir -p -- "$dst_dir"
  local w base
  for w in "${walls[@]}"; do
    base="$(basename -- "$w")"
    if [[ -e "$dst_dir/$base" ]]; then
      printf '  skip Pictures/wallpapers/%s (already exists)\n' "$base"
    else
      run cp -- "$w" "$dst_dir/$base"
      (( DRY_RUN )) || printf '  copy Pictures/wallpapers/%s\n' "$base"
    fi
  done
}

install_packages() {
  command -v pacman >/dev/null 2>&1 || {
    info "pacman not found - skipping package installation"
    return 0
  }

  local -a official=() aur=()
  mapfile -t official < <(grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/packages/official.txt")
  mapfile -t aur < <(grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/packages/aur.txt")

  if (( ${#official[@]} )); then
    info ""
    info ":: official packages (pacman)"
    run sudo pacman -S --needed "${official[@]}"
  fi

  if (( ${#aur[@]} )); then
    info ""
    info ":: AUR packages"
    if command -v yay >/dev/null 2>&1; then
      run yay -S --needed "${aur[@]}"
    elif command -v paru >/dev/null 2>&1; then
      run paru -S --needed "${aur[@]}"
    else
      info "warning: no AUR helper (yay/paru) found; install manually: ${aur[*]}"
    fi
  fi
}

main() {
  while (($#)); do
    case "$1" in
      -c|--copy)      MODE="copy" ;;
      -l|--link)      MODE="link" ;;
      -p|--packages)  WITH_PACKAGES=1 ;;
      -n|--dry-run)   DRY_RUN=1 ;;
      -t|--target)    [[ $# -ge 2 ]] || die "--target needs a directory"; TARGET="$2"; shift ;;
      -h|--help)      usage; exit 0 ;;
      *)              die "unknown option: $1 (try --help)" ;;
    esac
    shift
  done

  [[ -n "$TARGET" ]] || die "HOME is not set; pass --target DIR"
  [[ "$TARGET" != "/" ]] || die "refusing to install into /"
  [[ -d "$TARGET" ]] || die "target directory does not exist: $TARGET"
  [[ -d "$SRC_DIR" ]] || die "dotfiles/ not found next to install.sh"

  TARGET="$(cd -- "$TARGET" && pwd -P)"
  BACKUP_DIR="$TARGET/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

  discover_managed

  local mode_note=""
  if (( DRY_RUN )); then mode_note=" (dry run)"; fi

  info "arch-hyprland installer"
  info "  repo:   $REPO_DIR"
  info "  target: $TARGET"
  info "  mode:   $MODE$mode_note"
  info ""

  local rel
  for rel in "${MANAGED[@]}"; do
    install_one "$rel"
  done

  install_wallpapers

  if (( WITH_PACKAGES )); then
    install_packages
  fi

  info ""
  if (( BACKED_UP )); then
    info "backup of replaced files: $BACKUP_DIR"
  fi
  info "done."
  info "  reload Hyprland:  hyprctl reload"
  info "  reload Waybar:    pkill -SIGUSR2 waybar"
  info "  open a new shell for .bashrc changes to apply"
}

main "$@"