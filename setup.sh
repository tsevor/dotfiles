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
ln -s $root/bashrc               ~/.bashrc
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

fastfetch