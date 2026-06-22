# dotfiles

macOS development environment configuration for a Python/AWS/AI engineering workflow.
Managed via symlinks so edits in this repo take effect immediately in the shell.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Xcode Command Line Tools (`xcode-select --install`) — provides `git` for the clone.
  Homebrew installs them automatically if missing, so this is only needed to run the
  `git clone` below.

A Nerd Font is **installed for you** (`font-meslo-lg-nerd-font` via the Brewfile) — you
just set it as your terminal font afterward (see [First run](#first-run-on-a-new-machine)).

## First run on a new machine

```bash
git clone git@github.com:johnsosoka/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

The installer is idempotent and walks through every step on its own:

1. **Installs Homebrew** (if missing) and all packages/apps from the `Brewfile`.
2. **Sets up the shell** — Oh My Zsh, the Powerlevel10k theme, and the zsh plugins.
3. **Symlinks** `~/.zshrc`, `~/.p10k.zsh`, and `~/.gitconfig` back to this repo. Any
   existing file at a target path is backed up to `<filename>.bak` first.
4. **Prompts for your git name and email**, writing them to `~/.gitconfig.local`
   (machine-local, never committed). Name defaults to `John Sosoka`; email is required.

After it finishes:

- **Set your terminal font** to `MesloLGS NF` (iTerm2 → Settings → Profiles → Text →
  Font; Ghostty → `font-family = "MesloLGS NF"`). Any nerdfont-v3 font works, but the
  Powerlevel10k config was built against MesloLGS NF. Without it, prompt icons render as
  boxes.
- **Restart your shell** (or run `source ~/.zshrc`).

Re-running `install.sh` later is safe: installed packages are skipped, and an existing
`~/.gitconfig.local` is left untouched so the identity prompt does not repeat.

### Why the git identity is separate

The tracked `git/.gitconfig` holds only shared settings and pulls in your identity via
`[include] path = ~/.gitconfig.local`. This keeps your name/email out of the public repo
and lets each machine (personal vs. work) use a different email.

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
- `~/.local/bin` on `PATH` (pipx/Poetry tools) and `rbenv` auto-activated when present

### Homebrew Packages

| Category | Packages |
|---|---|
| Cloud / Infra | `awscli`, `terraform`, `gh` |
| Python | `python@3.12`, `pipx`, `poetry` |
| Ruby | `rbenv` |
| Git | `git`, `git-delta`, `git-lfs`, `git-filter-repo`, `lazygit` |
| Dev / lint | `pre-commit`, `shellcheck`, `yamllint` |
| Docs & diagrams | `pandoc`, `graphviz`, `mermaid-cli`, `d2`, `weasyprint`, `exiftool` |
| General CLI | `curl`, `wget`, `rsync`, `jq`, `tree`, `watch`, `vim`, `glow` |
| Runtimes | `node`, `openjdk` |

### Applications (casks)

| Category | Apps |
|---|---|
| Dev tools | `claude-code`, `iterm2`, `docker-desktop`, `intellij-idea`, `pycharm` |
| Notes & productivity | `obsidian`, `notion`, `joplin` |
| Security & network | `tailscale-app`, `gpg-suite`, `yubico-yubikey-manager` |
| Browsers & comms | `google-chrome`, `firefox`, `slack`, `zoom` |
| Fonts | `font-meslo-lg-nerd-font` |

## Customization

All configuration lives in this repo. Because the files are symlinked, any edit made
directly in the repo is reflected immediately — no re-run of `install.sh` required.

- **Shell config**: edit `zsh/.zshrc`
- **Prompt**: edit `zsh/.p10k.zsh`, or run `p10k configure` to regenerate it
- **Git config**: shared settings live in `git/.gitconfig`; your name/email live in
  `~/.gitconfig.local` (created by `install.sh`). Edit that file or re-run the script
  after removing it to change your identity
- **Packages**: edit `Brewfile`, then run `brew bundle` from the repo root
