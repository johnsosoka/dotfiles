# dotfiles

macOS development environment configuration for a Python/AWS/AI engineering workflow.
Managed via symlinks so edits in this repo take effect immediately in the shell.

## Prerequisites

- macOS (Apple Silicon or Intel)
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your terminal font.
  The Powerlevel10k config was built with nerdfont-v3. Any v3-compatible Nerd Font works
  (e.g., MesloLGS NF, JetBrainsMono NF).

## Installation

```bash
git clone git@github.com:johnsosoka/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Restart your shell or run `source ~/.zshrc` when the script finishes.

The script is idempotent — re-running it is safe. If a dotfile already exists at the
target path, it is backed up to `<filename>.bak` before the symlink is created.

## What Gets Installed

### Dotfiles (symlinked to `~/`)

| File | Source |
|---|---|
| `~/.zshrc` | `zsh/.zshrc` |
| `~/.p10k.zsh` | `zsh/.p10k.zsh` |
| `~/.gitconfig` | `git/.gitconfig` |

### Shell

- **Oh My Zsh** with the **Powerlevel10k** theme (classic powerline, 1-line compact,
  transient prompt)
- Plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`,
  `zsh-history-substring-search`

### Homebrew Packages

| Category | Packages |
|---|---|
| Cloud / Infra | `awscli`, `terraform`, `gh` |
| Python | `pyenv`, `poetry` |
| Git | `git`, `git-delta`, `git-lfs`, `lazygit` |
| GNU utils | `coreutils`, `findutils`, `gawk`, `gnu-sed`, `gnu-tar`, `grep` |
| General CLI | `curl`, `wget`, `rsync`, `jq`, `tree`, `watch`, `vim`, `glow`, `exiftool` |
| Runtimes | `node`, `openjdk` |
| Casks | `claude-code` |

## Customization

All configuration lives in this repo. Because the files are symlinked, any edit made
directly in the repo is reflected immediately — no re-run of `install.sh` required.

- **Shell config**: edit `zsh/.zshrc`
- **Prompt**: edit `zsh/.p10k.zsh`, or run `p10k configure` to regenerate it
- **Git config**: edit `git/.gitconfig` — update `[user]` name and email before first use
- **Packages**: edit `Brewfile`, then run `brew bundle` from the repo root
