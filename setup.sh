#!/usr/bin/env bash
set -e

root=$(realpath $(dirname $0))
cd $root

# only ask for sudo once
sudo -v
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup_bypass > /dev/null
cleanup() {
	sudo rm -f /etc/sudoers.d/setup_bypass
}
trap cleanup EXIT

sudo pacman -Syu --needed --noconfirm git base-devel

mkdir -p ~/.config/Code/User
mkdir -p ~/dev
mkdir -p ~/Pictures/screenshots

rm -rf ~/.config/hypr       ; ln -sfn $root/home/config/hypr       ~/.config
rm -rf ~/.config/wofi       ; ln -sfn $root/home/config/wofi       ~/.config
rm -rf ~/.config/alacritty  ; ln -sfn $root/home/config/alacritty  ~/.config
rm -rf ~/.config/micro      ; ln -sfn $root/home/config/micro      ~/.config
rm -rf ~/.config/waybar     ; ln -sfn $root/home/config/waybar     ~/.config
rm -rf ~/.config/fontconfig ; ln -sfn $root/home/config/fontconfig ~/.config
rm -rf ~/.config/gtk-3.0    ; ln -sfn $root/home/config/gtk-3.0    ~/.config
rm -rf ~/.config/gtk-4.0    ; ln -sfn $root/home/config/gtk-4.0    ~/.config
rm -rf ~/.config/qt5ct      ; ln -sfn $root/home/config/qt5ct      ~/.config
rm -rf ~/.config/qt6ct      ; ln -sfn $root/home/config/qt6ct      ~/.config
rm -rf ~/.config/xsettingsd ; ln -sfn $root/home/config/xsettingsd ~/.config
rm -rf ~/.config/xdg-desktop-portal ; ln -sfn $root/home/config/xdg-desktop-portal ~/.config

rm -f ~/.bashrc             ; ln -sfn $root/home/bashrc            ~/.bashrc
rm -f ~/.bash_aliases       ; ln -sfn $root/home/bash_aliases      ~/.bash_aliases
rm -f ~/.bash_profile       ; ln -sfn $root/home/bash_profile      ~/.bash_profile
rm -f ~/.gtkrc-2.0          ; ln -sfn $root/home/gtkrc-2.0         ~/.gtkrc-2.0

sudo cp $root/systemd/getty@tty1.service /etc/systemd/system/getty@tty1.service
sudo sed -i s/USER/$USER/ /etc/systemd/system/getty@tty1.service

sudo sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

cd ~/dev
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

cd $root

sudo pacman -Syu --needed --noconfirm - < packages.txt
yay -Syu --needed --noconfirm - < packages_aur.txt

fc-cache -fv
xdg-user-dirs-update

gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'Overpass Mono 11'

systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon
sudo systemctl enable bluetooth cups.socket cups.service

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

grep -Po '(?<=^MimeType=).*' /usr/share/applications/zen.desktop | \
	tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default zen.desktop {}

cd ~/dev
rm -rf immy
git clone https://github.com/ztchary/immy
cd immy
make immy
sudo make install

grep -Po '(?<=^MimeType=).*' /usr/share/applications/immy.desktop | \
	tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default immy.desktop {}

cd ~/dev
rm -rf restart
git clone https://github.com/ztchary/restart
cd restart
make restart
sudo make install

echo
fastfetch

echo -e "\e[93mRemember to configure:\e[0m"
echo -e "\e[93m    ~/.config/hypr/land/monitors.conf\e[0m"
echo -e "\e[93m    ~/.config/hypr/hyprlock.conf\e[0m"
echo -e "\e[93m    ~/.config/hypr/hyprpaper.conf\e[0m"
echo -e "\e[93m    ~/.config/hypr/autostart.conf\e[0m"
echo
echo -e "\e[93mThen reboot.\e[0m"
