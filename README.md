# basic_config_mac

Automated macOS development environment setup. One script to install apps, configure Zsh, and set up Neovim.

## What it does

### Interactive app installer

The script presents an interactive menu where you can select which apps to install via Homebrew. Navigate with arrow keys, toggle with Space, and confirm with Enter.

**Desktop apps (casks):**

- iTerm2
- Visual Studio Code
- Discord
- Setapp
- Claude Desktop
- Google Chrome
- Steam
- Spotify
- Microsoft Teams

**CLI tools (formulae):**

- jq — JSON processor
- htop — interactive process viewer
- fzf — fuzzy finder
- bat — cat with syntax highlighting
- ripgrep — fast recursive grep
- tree — directory structure viewer
- fd — fast file finder

### Zsh setup

- Installs Oh My Zsh
- Installs plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-vi-mode
- Installs Powerlevel10k theme
- Installs Meslo Nerd Font (required for Powerlevel10k icons)
- Copies preconfigured `.zshrc` and `.p10k.zsh`

Included shell aliases:

| Alias     | Command              |
|-----------|----------------------|
| `ll`      | `ls -lah`            |
| `gs`      | `git status`         |
| `ga`      | `git add`            |
| `gc`      | `git commit`         |
| `gp`      | `git push`           |
| `gl`      | `git pull`           |
| `gf`      | `git fetch`          |
| `..`      | `cd ..`              |
| `reload`  | `source ~/.zshrc`    |

### Neovim setup

- Installs Neovim and fd (Telescope dependency)
- Copies the `nvim/` config to `~/.config/nvim`
- Bootstraps lazy.nvim and installs all plugins
- Installs LSP servers via Mason (TypeScript, ESLint, Svelte, HTML, CSS, Lua, JSON)

## Usage

```bash
git clone https://github.com/raulvasile/basic_config_mac.git
cd basic_config_mac
chmod +x setup.sh
./setup.sh
```

The script is idempotent — already installed apps and tools are detected and skipped.

## Post-install: set terminal font

After running the setup script, configure your terminal to use the Meslo Nerd Font so that Powerlevel10k icons render correctly.

**iTerm2:**

1. Open iTerm2 > Settings (`Cmd + ,`)
2. Go to Profiles > Text
3. Under Font, select **MesloLGS NF**
4. Restart iTerm2

## Requirements

- macOS
- Internet connection (for Homebrew, git clones, and cask downloads)
