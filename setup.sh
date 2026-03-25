#!/usr/bin/env bash
set -e

root=$(realpath $(dirname $0))
cd $root

# allow the rest of the script to run without prompting for sudo again
sudo -v
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup_bypass > /dev/null
cleanup() {
	sudo rm -f /etc/sudoers.d/setup_bypass
}
trap cleanup EXIT

# make some directories for stuff to land in
mkdir -p ~/.config
mkdir -p ~/dev
mkdir -p ~/Pictures/screenshots

# link folders in .config, removing if needed
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

# link rc files, removing if needed
rm -f ~/.bashrc             ; ln -sfn $root/home/bashrc            ~/.bashrc
rm -f ~/.bash_aliases       ; ln -sfn $root/home/bash_aliases      ~/.bash_aliases
rm -f ~/.bash_profile       ; ln -sfn $root/home/bash_profile      ~/.bash_profile
rm -f ~/.gtkrc-2.0          ; ln -sfn $root/home/gtkrc-2.0         ~/.gtkrc-2.0


# get the suff needed for yay
sudo pacman -Syu --needed --noconfirm git base-devel

# if yay is installed, skip it
if ! command -v yay &> /dev/null
then
	# install yay
	cd ~/dev
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd ..
	rm -rf yay
fi

cd $root

# install packages from packages.txt and packages_aur.txt
sudo pacman -Syu --needed --noconfirm - < packages.txt
yay -Syu --needed --noconfirm - < packages_aur.txt

# update font cache
fc-cache -fv

# create default folders in home
xdg-user-dirs-update

# install service to automatically start hyprland on boot
sudo cp $root/systemd/getty@tty1.service /etc/systemd/system/getty@tty1.service
sudo sed -i s/USER/$USER/ /etc/systemd/system/getty@tty1.service

# disable power button, bound in hyprland config
sudo sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

# set some settings for theming
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'Overpass Mono 11'

# enable services
systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon
sudo systemctl enable bluetooth cups.socket cups.service

# configure zen to make it look nicer
zen-browser --headless --screenshot /dev/null > /dev/null 2>&1 &
sleep 1
pgrep zen-bin &> /dev/null && killall zen-bin
ZEN_USER_JS="$(find ~/.config/zen -maxdepth 1 -type d -name "*.Default (release)" | head -n 1)/user.js"
ZEN_SETTING1='user_pref("zen.view.experimental-no-window-controls", true);'
ZEN_SETTING2='user_pref("zen.theme.content-element-separation", 0);'
ZEN_SETTING3='user_pref("zen.welcome-screen.seen", true);'
grep -qF "$ZEN_SETTING1" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING1" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING2" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING2" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING3" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING3" >> "$ZEN_USER_JS"

# make zen default for its supported mime types
grep -Po '(?<=^MimeType=).*' /usr/share/applications/zen.desktop | \
	tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default zen.desktop {}

# install/update immy, an image viewer
cd ~/dev
if [ ! -d immy ]
then
	git clone https://github.com/ztchary/immy
	cd immy
else
	cd immy
	git pull
fi
make immy
sudo make install

# make immy default for its supported mime types
grep -Po '(?<=^MimeType=).*' /usr/share/applications/immy.desktop | \
	tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default immy.desktop {}

# install/update restart, a tool to restart programs
cd ~/dev
if [ ! -d restart ]
then
	git clone https://github.com/ztchary/restart
	cd restart
else
	cd restart
	git pull
fi
make restart
sudo make install

# print system info to look cool
echo
fastfetch

# some last instructions on system specific things
echo -e "\e[93m"
echo "Remember to configure:"
echo "    ~/.config/hypr/land/autostart.conf"
echo "    ~/.config/hypr/land/monitors.conf"
echo "    ~/.config/hypr/hyprlock.conf"
echo "    ~/.config/hypr/hyprpaper.conf"
echo
echo "Then reboot."
echo -e "\e[0m"
