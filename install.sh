#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[ ok ]\033[0m %s\n" "$1"; }

link_file() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup
    backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $dst to $backup"
    mv "$dst" "$backup"
  fi
  ln -s "$src" "$dst"
  ok "Linked $dst -> $src"
}

# --- Pre-flight safety checks ---
if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This installer targets macOS only (detected $(uname -s)). Aborting."
  exit 1
fi
if [[ "$(id -u)" -eq 0 ]]; then
  warn "Run as your normal user, not root/sudo — Homebrew refuses to run as root. Aborting."
  exit 1
fi

# --- Confirmation (skip with -y/--yes) ---
ASSUME_YES=0
if [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]]; then
  ASSUME_YES=1
fi

if [[ "$ASSUME_YES" -eq 0 && -t 0 ]]; then
  echo "This will configure your environment from: $DOTFILES_DIR"
  echo "  - Install Homebrew (if missing) + packages and apps from the Brewfile"
  echo "  - Install Oh My Zsh, Powerlevel10k, and zsh plugins"
  echo "  - Symlink ~/.zshrc, ~/.p10k.zsh, ~/.gitconfig (existing files are backed up)"
  echo "  - Prompt for your git name/email (saved to ~/.gitconfig.local)"
  for f in "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.p10k.zsh"; do
    if [[ -e "$f" && ! -L "$f" ]]; then
      warn "Existing $f will be backed up and replaced — merge anything you need from its .bak afterward."
    fi
  done
  read -r -p "Proceed? [y/N] " reply || reply=""
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    info "Aborted; nothing changed."
    exit 0
  fi
fi

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "Homebrew already installed"
fi

# A fresh Homebrew install does NOT add brew to the current shell's PATH, so load
# its environment here (covers Apple Silicon /opt/homebrew and Intel /usr/local)
# before running any brew command below.
if ! command -v brew &>/dev/null; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
fi

if ! command -v brew &>/dev/null; then
  warn "Homebrew is not on PATH after installation; cannot continue."
  exit 1
fi
ok "Homebrew ready ($(command -v brew))"

# Terraform lives in HashiCorp's tap (removed from homebrew-core under the BSL
# license change). Homebrew 6+ requires trusting third-party taps before install,
# so tap + trust it before `brew bundle` runs.
brew tap hashicorp/tap >/dev/null 2>&1 || true
if brew help trust &>/dev/null; then
  brew trust --tap hashicorp/tap >/dev/null 2>&1 || true
fi

info "Installing Homebrew packages..."
if ! brew bundle --file="$DOTFILES_DIR/Brewfile"; then
  warn "Some Homebrew packages failed to install. Continuing with shell setup."
  warn "Re-run later: brew bundle --file=\"$DOTFILES_DIR/Brewfile\""
fi

# --- Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  # KEEP_ZSHRC=yes: don't let the installer create/replace ~/.zshrc — our symlink owns it.
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  ok "Oh My Zsh already installed"
fi

# --- Powerlevel10k ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  ok "Powerlevel10k already installed"
fi

# --- Custom ZSH Plugins ---
install_plugin() {
  local name="$1" url="$2"
  local plugin_dir="$ZSH_CUSTOM/plugins/$name"
  if [[ ! -d "$plugin_dir" ]]; then
    info "Installing $name..."
    git clone --depth=1 "$url" "$plugin_dir"
  else
    ok "$name already installed"
  fi
}

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_plugin zsh-completions https://github.com/zsh-users/zsh-completions.git
install_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git

# --- Symlinks ---
info "Creating symlinks..."
link_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# --- Git identity (machine-local, kept out of the public repo) ---
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ -f "$GITCONFIG_LOCAL" ]]; then
  ok "Git identity already configured ($GITCONFIG_LOCAL)"
elif [[ ! -t 0 ]]; then
  warn "Non-interactive shell; skipping git identity prompt."
  warn "Create $GITCONFIG_LOCAL with a [user] name/email before committing."
else
  info "Configuring git identity (written to $GITCONFIG_LOCAL, never committed)"
  read -r -p "  Git user name [John Sosoka]: " git_name
  git_name="${git_name:-John Sosoka}"
  git_email=""
  while [[ -z "$git_email" ]]; do
    read -r -p "  Git email: " git_email
  done
  cat > "$GITCONFIG_LOCAL" <<EOF
[user]
	name = ${git_name}
	email = ${git_email}
EOF
  ok "Wrote git identity to $GITCONFIG_LOCAL"
fi

echo ""
ok "dotfiles installed. Restart your shell or run: source ~/.zshrc"
