#!/usr/bin/env bash

set -e

sudo pacman -Syu --needed --noconfirm fontforge

root=$(realpath $(dirname $0))
cd $root

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip
rm -rf patcher
unzip FontPatcher.zip -d patcher

# for some reason the official releases have an uncomfortably tall line height
# so the google fonts version, which is identical in every other way, is used

# curl -LO https://github.com/RedHatOfficial/Overpass/releases/download/v3.0.5/overpass-3.0.5.zip
# rm -rf overpass
# unzip overpass-3.0.5.zip -d overpass

# overpass/Overpass-3.0.5/webfonts/overpass-mono-webfont/overpass-mono-regular.ttf

mkdir -p out

./patcher/font-patcher \
	--removeligs --configfile config.cfg --complete --boxdrawing \
	google_fonts/OverpassMono-Regular.ttf \
	--outputdir out


sudo install -Dm644 out/OverpassMNerdFont-Regular.ttf -t /usr/share/fonts/TTF

fc-cache -fv
