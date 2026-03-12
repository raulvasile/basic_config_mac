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
- Node.js — JavaScript runtime (required by Mason LSP servers)

### Zsh setup

- Installs Oh My Zsh
- Installs plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-vi-mode
- Installs Powerlevel10k theme
- Installs Meslo Nerd Font (required for Powerlevel10k icons)
- Copies preconfigured `.zshrc` and `.p10k.zsh`

Included shell aliases:

| Alias       | Command              |
|-------------|----------------------|
| `ll`        | `ls -lah`            |
| `gs`        | `git status`         |
| `ggs`       | `git status`         |
| `ga`        | `git add`            |
| `gc`        | `git commit`         |
| `gp`        | `git push`           |
| `gl`        | `git pull`           |
| `gf`        | `git fetch`          |
| `..`        | `cd ..`              |
| `zshconfig` | `vim ~/.zshrc`       |
| `reload`    | `source ~/.zshrc`    |

### Neovim setup

- Installs Neovim and fd (Telescope dependency)
- Copies the `nvim/` config to `~/.config/nvim`
- Bootstraps lazy.nvim and installs all plugins
- Installs LSP servers via Mason (TypeScript, ESLint, Svelte, HTML, CSS, Lua, JSON)

### Neovim keybindings cheatsheet

**Navigation and search (Telescope):**

| Key              | Action               |
|------------------|----------------------|
| `<Space>ff`      | Find files           |
| `<Space>fg`      | Live grep in project |
| `<Space>fb`      | List open buffers    |
| `<Space>fr`      | Recent files         |
| `<Space>fd`      | Diagnostics list     |
| `<Space>fk`      | Keymaps              |

**LSP (active when a language server is attached):**

| Key              | Action               |
|------------------|----------------------|
| `gd`             | Go to definition     |
| `gD`             | Go to declaration    |
| `gr`             | References           |
| `gi`             | Implementation       |
| `K`              | Hover docs           |
| `<Space>rn`      | Rename symbol        |
| `<Space>ca`      | Code action          |
| `<Space>cf`      | Format file          |
| `[d` / `]d`      | Prev / next diagnostic |
| `<Space>e`       | Show diagnostic float |

**Git (gitsigns):**

| Key              | Action               |
|------------------|----------------------|
| `]g` / `[g`      | Next / prev hunk     |
| `<Space>gb`      | Blame current line   |
| `<Space>gp`      | Preview hunk         |
| `<Space>gs`      | Stage hunk           |
| `<Space>gr`      | Reset hunk           |
| `<Space>gd`      | Diff this file       |

**Diagnostics (trouble.nvim):**

| Key              | Action                    |
|------------------|---------------------------|
| `<Space>xx`      | Toggle diagnostics panel  |
| `<Space>xw`      | Workspace diagnostics     |
| `<Space>xd`      | Document diagnostics      |

**Editing:**

| Key              | Action                         |
|------------------|--------------------------------|
| `gcc`            | Toggle comment (line)          |
| `gc` (visual)    | Toggle comment (selection)     |
| `J` (visual)     | Move selected lines down       |
| `K` (visual)     | Move selected lines up         |
| `<Space>p` (visual) | Paste without losing register |
| `Ctrl+s`         | Save file                      |
| `Ctrl+h/j/k/l`  | Navigate between splits        |
| `Ctrl+d` / `Ctrl+u` | Half-page down/up (centered) |

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
