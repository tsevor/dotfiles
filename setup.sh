#!/usr/bin/env bash

root=$(realpath $(dirname $0))
cd $root

rm ~/.bashrc ~/.bash_profile

sudo pacman -Sy --needed --noconfirm git base-devel

mkdir -p ~/config
mkdir -p ~/dev

ln -s $root/config/hypr          ~/.config
ln -s $root/config/wofi          ~/.config
ln -s $root/config/alacritty     ~/.config
ln -s $root/config/micro         ~/.config
ln -s $root/config/waybar        ~/.config
ln -s $root/config/fontconfig    ~/.config
ln -s $root/config/gtk-3.0       ~/.config
ln -s $root/config/gtk-4.0       ~/.config
ln -s $root/config/qt5ct         ~/.config
ln -s $root/config/qt6ct         ~/.config
ln -s $root/config/xsettingsd    ~/.config


ln -s $root/gtkrc-2.0            ~/.gtkrc-2.0

ln -s $root/bashrc               ~/.bashrc
ln -s $root/bash_aliases         ~/.bash_aliases
ln -s $root/bash_profile         ~/.bash_profile

sudo cp $root/systemd/getty@tty1.service /etc/systemd/system/getty@tty1.service
sudo sed -i s/USER/$USER/ /etc/systemd/system/getty@tty1.service

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

yay -Syu --noconfirm - < packages.txt

systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon

fc-cache -fv

# configure zen
ZEN_PROFILE_PATH=$(find ~/.config/zen -maxdepth 1 -type d -name "*.Default (release)" | head -n 1)
ZEN_USER_JS="$ZEN_PROFILE_PATH/user.js"
ZEN_SETTING1='user_pref("zen.view.experimental-no-window-controls", true);'
ZEN_SETTING2='user_pref("zen.theme.content-element-separation", 0);'
grep -qF "$ZEN_SETTING1" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING1" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING2" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING2" >> "$ZEN_USER_JS"

fastfetch
