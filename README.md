# 📦 basic_config_mac — Mac Setup Script

Automate your macOS configuration for development: Zsh, Vim, CLI tools, VSCode, and more.

---

## ✅ What This Does

- Installs:
  - [Homebrew](https://brew.sh/)
  - [iTerm2](https://iterm2.com/)
  - [Visual Studio Code](https://code.visualstudio.com/)
  - [Vim](https://www.vim.org/) + preconfigured plugins
  - [Oh My Zsh](https://ohmyz.sh/) with:
    - `zsh-autosuggestions`
    - `zsh-syntax-highlighting`
    - `powerlevel10k` (theme)
  - Meslo Nerd Font for terminal icons and glyphs
  - CLI tools: `jq`, `htop`, `fzf`, `bat`, `ripgrep`, `tree`, `git`
- Copies:
  - Custom `.vimrc` with `vim-plug`
  - Preconfigured `.zshrc`
  - Preconfigured `.p10k.zsh`
- Runs `PlugInstall` to install Vim plugins

---

## 🚀 How to Use

```bash
git clone https://github.com/raulvasile/basic_config_mac.git
cd basic_config_mac
chmod +x setup.sh
./setup.sh
```
