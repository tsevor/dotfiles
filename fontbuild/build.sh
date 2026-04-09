#!/usr/bin/env bash
set -e

sudo pacman -Syu --needed --noconfirm fontforge ttf-overpass

root=$(realpath $(dirname $0))
cd "$root"

if ! [ -d patcher ]
then
	curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip
	unzip FontPatcher.zip -d patcher
	rm FontPatcher.zip
fi

mkdir -p references
cp /usr/share/fonts/TTF/overpass-mono-regular.ttf references/

mkdir -p out
rm -rf out/*

./patcher/font-patcher \
	--removeligs --configfile config.cfg --complete --boxdrawing \
	references/overpass-mono-regular.ttf \
	--outputdir out

patched_font=(out/*NerdFont*.ttf)

# sudo install -Dm644 "${patched_font[0]}" -t /usr/share/fonts/TTF

fontforge -lang=py -script resize.py \
	references/overpass-mono-regular.ttf \
	"${patched_font[0]}" \
	out/OverpassMonoNerdFont-Regular.ttf

sudo install -Dm644 out/OverpassMonoNerdFont-Regular.ttf -t /usr/share/fonts/TTF

fc-cache -fv
