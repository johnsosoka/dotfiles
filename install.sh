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
  elif [[ -f "$dst" ]]; then
    warn "Backing up existing $dst to ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -s "$src" "$dst"
  ok "Linked $dst -> $src"
}

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "Homebrew already installed"
fi

info "Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# --- Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  ok "Oh My Zsh already installed"
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  ok "Powerlevel10k already installed"
fi

# --- Custom ZSH Plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
  [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
)

for plugin in "${!plugins[@]}"; do
  plugin_dir="$ZSH_CUSTOM/plugins/$plugin"
  if [[ ! -d "$plugin_dir" ]]; then
    info "Installing $plugin..."
    git clone --depth=1 "${plugins[$plugin]}" "$plugin_dir"
  else
    ok "$plugin already installed"
  fi
done

# --- Symlinks ---
info "Creating symlinks..."
link_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

echo ""
ok "dotfiles installed. Restart your shell or run: source ~/.zshrc"
