#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd $HOME/dotfiles

# Install homebrew
./homebrew/install.sh 2>&1

# Upgrade homebrew
echo "› brew update"
brew update
brew tap Homebrew/bundle

# Install software

# Run Homebrew through the Brewfile
echo "› brew bundle"
brew bundle

# find the installers and run them iteratively
find . -name install.sh | while read installer ; do sh -c "${installer}" ; done

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

FILE=~/.zshrc.pre-oh-my-zsh
if test -f "$FILE"; then
    rm ~/.zshrc.pre-oh-my-zsh
    rm ~/.zshrc
    ln -s "$(pwd)/zsh/zshrc.symlink" ~/.zshrc
fi

## Install powerline fonts
echo "› installing powerline fonts"
git clone https://github.com/powerline/fonts.git
pushd fonts
./install.sh
popd

rm -rf ./fonts

echo "Set your iTerm font to a powerline font for the zsh theme to work." 


