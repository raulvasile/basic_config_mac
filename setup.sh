#!/bin/bash

echo "Starting Mac setup..."

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

brew install vim
brew install node

brew tap homebrew/cask-fonts
brew install --cask visual-studio-code
brew install --cask font-meslo-lg-nerd-font

brew install jq htop fzf bat ripgrep tree git

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

npm i -g n

sudo mkdir -p /usr/local/n
sudo chown -R $(whoami) /usr/local/n
sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 2>/dev/null

echo "Copying dotfiles..."

cp ./vim/.vimrc ~/.vimrc
cp ./zsh/.zshrc ~/.zshrc
cp ./zsh/.p10k.zsh ~/.p10k.zsh

echo "Setup complete!"

