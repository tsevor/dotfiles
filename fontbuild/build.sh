#!/usr/bin/env bash

set -e

sudo pacman -Syu --needed --noconfirm fontforge

root=$(realpath $(dirname $0))
cd $root

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip
rm -rf patcher
unzip FontPatcher.zip -d patcher

curl -LO https://github.com/RedHatOfficial/Overpass/releases/download/v3.0.5/overpass-3.0.5.zip
rm -rf overpass
unzip overpass-3.0.5.zip -d overpass

mkdir -p out

./patcher/font-patcher \
	--removeligs --configfile config.cfg --complete --boxdrawing --quiet \
	overpass/Overpass-3.0.5/webfonts/overpass-mono-webfont/overpass-mono-regular.ttf \
	--outputdir out

sudo install -Dm644 out/OverpassMNerdFont-Regular.ttf -t /usr/share/fonts/TTF

fc-cache -fv
