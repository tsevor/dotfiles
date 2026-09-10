#!/usr/bin/env bash

IMGS="$HOME/.config/hypr/images/bg"

new_wall=$(
for f in $IMGS/*; do
	[ -e $f ] || continue;
	name=$(basename ${f%.*})
	printf 'img:%s:text:%s\n' "$f" "$name"
done | wofi --dmenu --no-action -D image_size=256 -D height=1024 | cut -d: -f2
)

hyprctl hyprpaper wallpaper ",$new_wall"
