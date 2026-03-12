#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${BLUE}  $1${RESET}"
  echo -e "${BOLD}${BLUE}══════════════════════════════════════════════${RESET}"
  echo ""
}

print_step()  { echo -e "${CYAN}▶ $1${RESET}"; }
print_ok()    { echo -e "${GREEN}✔ $1${RESET}"; }
print_warn()  { echo -e "${YELLOW}⚠ $1${RESET}"; }
print_skip()  { echo -e "${YELLOW}⟳ Skipping — $1 is already installed.${RESET}"; }
print_error() { echo -e "${RED}✘ $1${RESET}"; }

is_formula_installed() { brew list --formula 2>/dev/null | grep -qx "$1"; }
is_cask_installed()    { brew list --cask    2>/dev/null | grep -qx "$1"; }
is_app_installed()     { [ -d "/Applications/$1.app" ] || [ -d "$HOME/Applications/$1.app" ]; }
is_command_installed() { command -v "$1" &>/dev/null; }

install_cask() {
  local cask="$1" label="${2:-$1}"
  if is_cask_installed "$cask"; then
    print_skip "$label"
  else
    print_step "Installing $label…"
    brew install --cask "$cask" && print_ok "$label installed." || print_error "Failed to install $label."
  fi
}

install_formula() {
  local formula="$1" label="${2:-$1}"
  if is_formula_installed "$formula"; then
    print_skip "$label"
  else
    print_step "Installing $label…"
    brew install "$formula" && print_ok "$label installed." || print_error "Failed to install $label."
  fi
}

declare -a APP_CATALOGUE=(
  "iterm2|iTerm2|cask|iterm2|cask"
  "vscode|Visual Studio Code|cask|visual-studio-code|cask"
  "neovim|Neovim|formula|neovim|formula"
  "jq|jq|formula|jq|formula"
  "htop|htop|formula|htop|formula"
  "fzf|fzf|formula|fzf|formula"
  "bat|bat|formula|bat|formula"
  "ripgrep|ripgrep (rg)|formula|ripgrep|formula"
  "tree|tree|formula|tree|formula"
  "git|git|formula|git|formula"
  "fd|fd|formula|fd|formula"
  "discord|Discord|cask|discord|cask"
  "setapp|Setapp|cask|setapp|cask"
  "claude|Claude Desktop|cask|claude|cask"
  "chrome|Google Chrome|cask|google-chrome|cask"
  "steam|Steam|cask|steam|cask"
  "spotify|Spotify|cask|spotify|cask"
  "teams|Microsoft Teams|cask|microsoft-teams|cask"
)

show_menu() {
  print_header "📦 macOS Setup — Select What to Install"
  echo -e "  ${BOLD}↑/↓${RESET} navigate  ${BOLD}Space${RESET} toggle  ${BOLD}a${RESET} all  ${BOLD}n${RESET} none  ${BOLD}Enter${RESET} confirm\n"
  echo -e "  ${GREEN}[x]${RESET} will install   ${YELLOW}[~]${RESET} already installed   [ ] skip\n"

  local -a KEYS=() LABELS=() SELECTED=() IS_INSTALLED=()

  for entry in "${APP_CATALOGUE[@]}"; do
    IFS='|' read -r key label type brew_name check_method <<< "$entry"
    KEYS+=("$key")
    LABELS+=("$label")

    local already=false
    case "$check_method" in
      cask)    is_cask_installed    "$brew_name" && already=true ;;
      formula) is_formula_installed "$brew_name" && already=true ;;
    esac

    IS_INSTALLED+=("$already")
    $already && SELECTED+=(0) || SELECTED+=(1)
  done

  local count=${#KEYS[@]}
  local cursor=0

  tput civis 

  render_menu() {
    tput cup $(($(tput lines) - count - 5)) 0 2>/dev/null || true
    for i in $(seq 0 $((count - 1))); do
      local prefix="  "
      [ "$i" -eq "$cursor" ] && prefix="${BOLD}${BLUE}▶ ${RESET}"

      local checkbox
      if [ "${IS_INSTALLED[$i]}" = "true" ]; then
        checkbox="${YELLOW}[~]${RESET}"
      elif [ "${SELECTED[$i]}" -eq 1 ]; then
        checkbox="${GREEN}[x]${RESET}"
      else
        checkbox="[ ]"
      fi

      printf "%s%s %-32s\n" "$prefix" "$(echo -e "$checkbox")" "${LABELS[$i]}"
    done
    echo ""
    echo -e "  ${BOLD}↑/↓${RESET} navigate  ${BOLD}Space${RESET} toggle  ${BOLD}a${RESET} all  ${BOLD}n${RESET} none  ${BOLD}Enter${RESET} confirm"
  }

  for _ in $(seq 0 $((count + 5))); do echo ""; done
  render_menu

  while true; do
    IFS= read -rsn1 key
    case "$key" in
      $'\x1b')
        read -rsn2 -t 0.1 key2
        case "$key2" in
          '[A') [ "$cursor" -gt 0 ] && ((cursor--)) ;;
          '[B') [ "$cursor" -lt $((count-1)) ] && ((cursor++)) ;;
        esac
        ;;
      ' ')
        if [ "${IS_INSTALLED[$cursor]}" = "false" ]; then
          [ "${SELECTED[$cursor]}" -eq 1 ] && SELECTED[$cursor]=0 || SELECTED[$cursor]=1
        fi
        ;;
      'a') for i in $(seq 0 $((count-1))); do [ "${IS_INSTALLED[$i]}" = "false" ] && SELECTED[$i]=1; done ;;
      'n') for i in $(seq 0 $((count-1))); do [ "${IS_INSTALLED[$i]}" = "false" ] && SELECTED[$i]=0; done ;;
      '') break ;;
    esac
    render_menu
  done

  tput cnorm
  echo ""

  INSTALL_QUEUE=()
  for i in $(seq 0 $((count-1))); do
    [ "${SELECTED[$i]}" -eq 1 ] && [ "${IS_INSTALLED[$i]}" = "false" ] && INSTALL_QUEUE+=("${KEYS[$i]}")
  done
}

run_installs() {
  if [ "${#INSTALL_QUEUE[@]}" -eq 0 ]; then
    print_warn "Nothing selected. Skipping app installs."
    return
  fi

  print_header "🚀 Installing Selected Apps"

  for key in "${INSTALL_QUEUE[@]}"; do
    for entry in "${APP_CATALOGUE[@]}"; do
      IFS='|' read -r ekey label type brew_name check_method <<< "$entry"
      if [ "$ekey" = "$key" ]; then
        case "$type" in
          cask)    install_cask    "$brew_name" "$label" ;;
          formula) install_formula "$brew_name" "$label" ;;
        esac
      fi
    done
  done
}

setup_zsh() {
  print_header "🐚 Setting Up Zsh"

  local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_step "Installing Oh My Zsh…"
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_ok "Oh My Zsh installed."
  else
    print_skip "Oh My Zsh"
  fi

  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_step "Installing zsh-autosuggestions…"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  else
    print_skip "zsh-autosuggestions"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_step "Installing zsh-syntax-highlighting…"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  else
    print_skip "zsh-syntax-highlighting"
  fi

  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    print_step "Installing Powerlevel10k…"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    print_skip "Powerlevel10k"
  fi

  if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc" && print_ok ".zshrc copied."
  fi
  if [ -f "$SCRIPT_DIR/zsh/.p10k.zsh" ]; then
    cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh" && print_ok ".p10k.zsh copied."
  fi

  # Meslo Nerd Font (required for Powerlevel10k icons)
  if ! system_profiler SPFontsDataType 2>/dev/null | grep -qi "MesloLGS"; then
    install_cask "font-meslo-lg-nerd-font" "Meslo Nerd Font"
  else
    print_skip "Meslo Nerd Font"
  fi

  print_ok "Zsh setup complete."
}

setup_neovim() {
  print_header "✏️  Setting Up Neovim"

  local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local NVIM_CONFIG="$HOME/.config/nvim"

  if ! is_formula_installed "neovim"; then
    print_step "Installing Neovim…"
    brew install neovim && print_ok "Neovim installed."
  else
    print_skip "Neovim"
  fi

  if ! is_formula_installed "fd"; then
    install_formula "fd" "fd (Telescope dependency)"
  fi

  if [ -d "$SCRIPT_DIR/nvim" ]; then
    print_step "Copying Neovim config…"
    mkdir -p "$NVIM_CONFIG"
    cp -r "$SCRIPT_DIR/nvim/"* "$NVIM_CONFIG/"
    print_ok "Neovim config installed at $NVIM_CONFIG"
  else
    print_warn "No nvim/ directory found in repo — skipping config copy."
  fi

  print_step "Bootstrapping lazy.nvim and installing plugins (this may take a minute)…"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null && print_ok "Neovim plugins installed." \
    || print_warn "Plugin install had warnings — open nvim once to check."

  print_step "Installing LSP servers via Mason…"
  nvim --headless \
    -c "MasonInstall ts_ls eslint svelte html cssls lua_ls jsonls" \
    -c "sleep 30" \
    -c "qa" 2>/dev/null \
    && print_ok "LSP servers installed." \
    || print_warn "LSP install may need a moment — open nvim and run :MasonInstall if needed."

  print_ok "Neovim setup complete."
}

main() {
  print_header "🍎 basic_config_mac — Extended Setup"
  echo -e "  ${CYAN}Automate your macOS dev environment setup.${RESET}\n"

  if ! is_command_installed "brew"; then
    print_step "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    print_ok "Homebrew installed."
  else
    print_skip "Homebrew"
    brew update --quiet
  fi

  show_menu

  run_installs

  echo ""
  read -rp "$(echo -e "${BOLD}Set up Zsh + Oh My Zsh + Powerlevel10k? [Y/n] ${RESET}")" zsh_ans
  [[ "${zsh_ans,,}" != "n" ]] && setup_zsh

  echo ""
  read -rp "$(echo -e "${BOLD}Set up Neovim + plugins + LSP servers? [Y/n] ${RESET}")" nvim_ans
  [[ "${nvim_ans,,}" != "n" ]] && setup_neovim

  print_header "✅ Setup Complete!"
  echo -e "  Restart your terminal (sau ${CYAN}exec zsh${RESET}) pentru a aplica modificările.\n"
  echo -e "  ${BOLD}Neovim keymaps utile:${RESET}"
  echo -e "  ${CYAN}<Space>ff${RESET}  — caută fișiere    ${CYAN}<Space>fg${RESET}  — grep în proiect"
  echo -e "  ${CYAN}<Space>xx${RESET}  — diagnostics       ${CYAN}<Space>ca${RESET}  — code action"
  echo -e "  ${CYAN}gd${RESET}         — go to definition  ${CYAN}K${RESET}          — hover docs"
  echo -e "  ${CYAN}<Space>gb${RESET}  — git blame         ${CYAN}]g / [g${RESET}    — next/prev hunk\n"
}

main "$@"
