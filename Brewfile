# =====================================================================
# Brewfile — portable macOS dev environment
# Install/refresh with:  brew bundle --file=Brewfile
# =====================================================================

# --- Cloud / Infra ---
brew "awscli"
brew "terraform"
brew "gh"

# --- Python (brew-managed) ---
brew "python@3.12"   # primary interpreter (provides python3)
brew "pipx"          # install Python CLI apps in isolated venvs
brew "poetry"        # project/dependency management

# --- Ruby ---
brew "rbenv"         # Ruby version management (shadows macOS system ruby)

# --- Git ---
brew "git"
brew "git-delta"     # better diffs — wired up in git/.gitconfig
brew "git-lfs"
brew "git-filter-repo"
brew "lazygit"

# --- Dev / lint essentials ---
brew "pre-commit"
brew "shellcheck"
brew "yamllint"

# --- Docs & diagrams ---
brew "pandoc"
brew "graphviz"
brew "mermaid-cli"
brew "d2"
brew "weasyprint"
brew "exiftool"

# --- General CLI ---
brew "curl"
brew "wget"
brew "rsync"
brew "jq"
brew "tree"
brew "watch"
brew "vim"           # latest vim (shadows macOS system vim)
brew "glow"

# --- Runtimes ---
brew "node"
brew "openjdk"

# =====================================================================
# Casks — fonts, CLI apps, and GUI apps
# =====================================================================

# --- Fonts ---
cask "font-meslo-lg-nerd-font"

# --- Dev tools ---
cask "claude-code"
cask "iterm2"
cask "docker-desktop"
cask "intellij-idea"
cask "pycharm"

# --- Notes & productivity ---
cask "obsidian"
cask "notion"
cask "joplin"

# --- Security & network ---
cask "tailscale-app"
cask "gpg-suite"
cask "yubico-yubikey-manager"

# --- Browsers & comms ---
cask "google-chrome"
cask "firefox"
cask "slack"
cask "zoom"
