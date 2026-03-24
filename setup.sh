#!/usr/bin/env bash

root=$(realpath $(dirname $0))
cd $root

rm ~/.bashrc ~/.bash_profile

sudo pacman -Sy --needed --noconfirm git base-devel

mkdir -p ~/.config
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

ln -s $root/bashrc               ~/.bashrc
ln -s $root/bash_aliases         ~/.bash_aliases
ln -s $root/bash_profile         ~/.bash_profile
ln -s $root/gtkrc-2.0            ~/.gtkrc-2.0

sudo cp $root/systemd/getty@tty1.service /etc/systemd/system/getty@tty1.service
sudo sed -i s/USER/$USER/ /etc/systemd/system/getty@tty1.service

cd ~/dev
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

cd $root

sudo pacman -Syu --noconfirm - < packages.txt
yay -Syu --noconfirm - < packages_aur.txt

fc-cache -fv

gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'Overpass Mono 11'

systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon

# configure zen
zen-browser --headless --screenshot /dev/null > /dev/null 2>&1 &
sleep 1
pkill zen-bin
ZEN_USER_JS="$(find ~/.config/zen -maxdepth 1 -type d -name "*.Default (release)" | head -n 1)/user.js"
ZEN_SETTING1='user_pref("zen.view.experimental-no-window-controls", true);'
ZEN_SETTING2='user_pref("zen.theme.content-element-separation", 0);'
ZEN_SETTING3='user_pref("zen.welcome-screen.seen", true);'
grep -qF "$ZEN_SETTING1" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING1" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING2" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING2" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING3" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING3" >> "$ZEN_USER_JS"

grep -Po '(?<=^MimeType=).*' /usr/share/applications/zen.desktop | tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default zen.desktop {}

cd ~/dev
git clone https://github.com/ztchary/immy
cd immy
make immy
sudo make install

grep -Po '(?<=^MimeType=).*' /usr/share/applications/immy.desktop | tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default immy.desktop {}

cd ~/dev
git clone https://github.com/ztchary/restart
cd restart
make restart
sudo make install


fastfetch



echo -e "\e[31mRemember to configure:\e[0m"
echo -e "\e[31m    .config/hypr/land/monitors.conf\e[0m"
echo -e "\e[31m    .config/hypr/hyprlock.conf\e[0m"
