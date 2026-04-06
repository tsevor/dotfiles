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

# link folders in .config, removing if needed
rm -rf ~/.config/hypr       ; ln -s $root/home/config/hypr       ~/.config
rm -rf ~/.config/wofi       ; ln -s $root/home/config/wofi       ~/.config
rm -rf ~/.config/alacritty  ; ln -s $root/home/config/alacritty  ~/.config
rm -rf ~/.config/micro      ; ln -s $root/home/config/micro      ~/.config
rm -rf ~/.config/waybar     ; ln -s $root/home/config/waybar     ~/.config
rm -rf ~/.config/fontconfig ; ln -s $root/home/config/fontconfig ~/.config
rm -rf ~/.config/gtk-3.0    ; ln -s $root/home/config/gtk-3.0    ~/.config
rm -rf ~/.config/gtk-4.0    ; ln -s $root/home/config/gtk-4.0    ~/.config
rm -rf ~/.config/qt5ct      ; ln -s $root/home/config/qt5ct      ~/.config
rm -rf ~/.config/qt6ct      ; ln -s $root/home/config/qt6ct      ~/.config
rm -rf ~/.config/xsettingsd ; ln -s $root/home/config/xsettingsd ~/.config
rm -rf ~/.config/xdg-desktop-portal ; ln -s $root/home/config/xdg-desktop-portal ~/.config

# link rc files, removing if needed
rm -f ~/.bashrc             ; ln -s $root/home/bashrc            ~/.bashrc
rm -f ~/.bash_aliases       ; ln -s $root/home/bash_aliases      ~/.bash_aliases
rm -f ~/.bash_profile       ; ln -s $root/home/bash_profile      ~/.bash_profile
rm -f ~/.gtkrc-2.0          ; ln -s $root/home/gtkrc-2.0         ~/.gtkrc-2.0


# install cachyos repos and keyring
if ! grep -q "cachyos" /etc/pacman.conf
then
	curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
	tar xvf cachyos-repo.tar.xz
	cd cachyos-repo
	sed -i 's/pacman /pacman --noconfirm /g' cachyos-repo.sh
	sudo bash cachyos-repo.sh --install
	cd ..
	rm -rf cachyos-repo.tar.xz cachyos-repo
fi

# install yay using cachyos repo
sudo pacman -Syu --needed --noconfirm yay

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
sudo systemctl enable bluetooth cups.socket udisks2.service

# configure zen to make it look nicer and function better
if [ ! -d ~/.config/zen ]
then
	zen-browser --headless --screenshot /dev/null &> /dev/null &
	sleep 5
	killall -q zen-bin
	mkdir -p ~/.config/zen
fi

ZEN_USER_JS="$(find ~/.config/zen -maxdepth 1 -type d -name "*.Default (release)" | head -n 1)/user.js"

ZEN_SETTING1='user_pref("zen.view.experimental-no-window-controls", true);'
ZEN_SETTING2='user_pref("zen.theme.content-element-separation", 0);'
ZEN_SETTING3='user_pref("zen.welcome-screen.seen", true);'
ZEN_SETTING4='user_pref("zen.window-sync.enabled", false);'

grep -qF "$ZEN_SETTING1" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING1" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING2" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING2" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING3" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING3" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING4" "$ZEN_USER_JS" 2>/dev/null || echo "$ZEN_SETTING4" >> "$ZEN_USER_JS"

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

cd $root

# ask user if they want the extra packages
if ! pacman -Qq - < packages_extra.txt > /dev/null
then
	echo "Extra packages:"
	cat packages_extra.txt
	read -p "Install extra packages? [y/N] " -r < /dev/tty
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		yay -Syu --needed --noconfirm - < packages_extra.txt
	fi
else
	echo "All extra packages are already installed."
fi

# run manual configuration script for
# ~/.config/hypr/land/autostart.conf
# ~/.config/hypr/land/monitors.conf
# ~/.config/hypr/hyprlock.conf
# ~/.config/hypr/hyprpaper.conf
cd $root
python3 $root/settings.py

# reload to apply the changes made if applicable
[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprctl reload

# print system info to look cool
echo
fastfetch

# final instruction
echo -e "\e[93mReboot to apply all changes.\e[0m"
