#!/usr/bin/env bash
set -e

mkdir -p ~/dev
cd ~/dev

sudo pacman -Syu --needed --noconfirm git

[ ! -d ~/dev/dotfiles ] && git clone https://github.com/tsevor/dotfiles
cd ~/dev/dotfiles
git pull

bash ~/dev/dotfiles/setup.sh
