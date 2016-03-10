#!/usr/bin/env bash
#
# Run all dotfiles installers.

set -e

cd $HOME/.dotfiles

# Install homebrew
$HOME/.dotfiles/homebrew/install.sh 2>&1

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
