#!/usr/bin/env bash
set -e

root=$(realpath $(dirname $0))
cd "$root"

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
rm -rf ~/.config/hypr       ; ln -s "$root/home/config/hypr"       ~/.config
rm -rf ~/.config/wofi       ; ln -s "$root/home/config/wofi"       ~/.config
rm -rf ~/.config/alacritty  ; ln -s "$root/home/config/alacritty"  ~/.config
rm -rf ~/.config/micro      ; ln -s "$root/home/config/micro"      ~/.config
rm -rf ~/.config/waybar     ; ln -s "$root/home/config/waybar"     ~/.config
rm -rf ~/.config/fontconfig ; ln -s "$root/home/config/fontconfig" ~/.config
rm -rf ~/.config/gtk-3.0    ; ln -s "$root/home/config/gtk-3.0"    ~/.config
rm -rf ~/.config/gtk-4.0    ; ln -s "$root/home/config/gtk-4.0"    ~/.config
rm -rf ~/.config/qt5ct      ; ln -s "$root/home/config/qt5ct"      ~/.config
rm -rf ~/.config/qt6ct      ; ln -s "$root/home/config/qt6ct"      ~/.config
rm -rf ~/.config/xarchiver  ; ln -s "$root/home/config/xarchiver"  ~/.config
rm -rf ~/.config/xsettingsd ; ln -s "$root/home/config/xsettingsd" ~/.config
rm -rf ~/.config/xdg-desktop-portal ; ln -s "$root/home/config/xdg-desktop-portal" ~/.config

# link rc files, removing if needed
rm -f ~/.bashrc             ; ln -s "$root/home/bashrc"            ~/.bashrc
rm -f ~/.bash_aliases       ; ln -s "$root/home/bash_aliases"      ~/.bash_aliases
rm -f ~/.bash_profile       ; ln -s "$root/home/bash_profile"      ~/.bash_profile
rm -f ~/.gtkrc-2.0          ; ln -s "$root/home/gtkrc-2.0"         ~/.gtkrc-2.0

# if root has .gtkrc-2.0
if ! sudo test -f /root/.gtkrc-2.0
then
	read -p "Do evil symlink configs to root user? [y/N] " -r < /dev/tty
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo rm -rf /root/.config/hypr       ; sudo ln -s "$root/home/config/hypr"       /root/.config
		sudo rm -rf /root/.config/wofi       ; sudo ln -s "$root/home/config/wofi"       /root/.config
		sudo rm -rf /root/.config/alacritty  ; sudo ln -s "$root/home/config/alacritty"  /root/.config
		sudo rm -rf /root/.config/micro      ; sudo ln -s "$root/home/config/micro"      /root/.config
		sudo rm -rf /root/.config/waybar     ; sudo ln -s "$root/home/config/waybar"     /root/.config
		sudo rm -rf /root/.config/fontconfig ; sudo ln -s "$root/home/config/fontconfig" /root/.config
		sudo rm -rf /root/.config/gtk-3.0    ; sudo ln -s "$root/home/config/gtk-3.0"    /root/.config
		sudo rm -rf /root/.config/gtk-4.0    ; sudo ln -s "$root/home/config/gtk-4.0"    /root/.config
		sudo rm -rf /root/.config/qt5ct      ; sudo ln -s "$root/home/config/qt5ct"      /root/.config
		sudo rm -rf /root/.config/qt6ct      ; sudo ln -s "$root/home/config/qt6ct"      /root/.config
		sudo rm -rf /root/.config/xarchiver  ; sudo ln -s "$root/home/config/xarchiver"  /root/.config
		sudo rm -rf /root/.config/xsettingsd ; sudo ln -s "$root/home/config/xsettingsd" /root/.config
		sudo rm -rf /root/.config/xdg-desktop-portal ; sudo ln -s "$root/home/config/xdg-desktop-portal" /root/.config

		sudo rm -f /root/.bashrc             ; sudo ln -s "$root/home/bashrc"            /root/.bashrc
		sudo rm -f /root/.bash_aliases       ; sudo ln -s "$root/home/bash_aliases"      /root/.bash_aliases
		sudo rm -f /root/.bash_profile       ; sudo ln -s "$root/home/bash_profile"      /root/.bash_profile
		sudo rm -f /root/.gtkrc-2.0          ; sudo ln -s "$root/home/gtkrc-2.0"         /root/.gtkrc-2.0
	fi
fi


# create file for untracked machine specific config in hyprland
tee ~/.config/hypr/land/machine.conf > /dev/null << EOF
# this file is for machine specific config untracked by git
# or to make your own small changes without git yelling at you
EOF

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
pacman -Qq yay > /dev/null || sudo pacman -Syu --needed --noconfirm yay

cd "$root"

# syu no matter what just in case it passes through the whole script
sudo pacman -Syu --noconfirm

# install packages from packages.txt and packages_aur.txt
pacman -Qq - < packages.txt > /dev/null || sudo pacman -Syu --needed --noconfirm - < packages.txt 2>&1 /dev/null
yay -Qq - < packages_aur.txt > /dev/null || yay -Syu --needed --noconfirm - < packages_aur.txt 2>&1 /dev/null

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
gsettings set org.gnome.desktop.interface monospace-font-name 'monospace 12'

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

grep -qF "$ZEN_SETTING1" "$ZEN_USER_JS" 2> /dev/null || echo "$ZEN_SETTING1" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING2" "$ZEN_USER_JS" 2> /dev/null || echo "$ZEN_SETTING2" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING3" "$ZEN_USER_JS" 2> /dev/null || echo "$ZEN_SETTING3" >> "$ZEN_USER_JS"
grep -qF "$ZEN_SETTING4" "$ZEN_USER_JS" 2> /dev/null || echo "$ZEN_SETTING4" >> "$ZEN_USER_JS"

# make zen default for its supported mime types
grep -Po '(?<=^MimeType=).*' /usr/share/applications/zen.desktop | \
	tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default zen.desktop {}

# install/update immy, an image viewer
cd ~/dev
if [ ! -d immy ]
then
	git clone https://github.com/ztchary/immy
	cd immy
	make immy
	sudo make install
	# make immy default for its supported mime types
	grep -Po '(?<=^MimeType=).*' /usr/share/applications/immy.desktop | \
		tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default immy.desktop {}
else
	cd immy
	if ! git pull | grep -q "Already up to date."
	then
		make immy
		sudo make install
	fi
fi

# install/update restart, a tool to restart programs
cd ~/dev
if [ ! -d restart ]
then
	git clone https://github.com/ztchary/restart
	cd restart
	make restart
	sudo make install
else
	cd restart
	if ! git pull | grep -q "Already up to date."
	then
		make restart
		sudo make install
	fi
fi

cd "$root"

# install windows fonts
if [ ! -d /usr/share/fonts/windows ]
then
	curl -LO f.slambodia.com/winfonts.tar.gz
	tar xzvf winfonts.tar.gz winfonts
	sudo install -Dm644 winfonts/* -t /usr/share/fonts/windows
	rm -rf winfonts.tar.gz winfonts
fi

# evil hardcoded manual install of custom nerd font
if [ ! -f /usr/share/fonts/TTF/OverpassMonoNerdFont-Regular.ttf ]
then
	./fontbuild/build.sh
else
	echo "Overpass Mono Nerd Font already installed."
	echo "You may need to manually run the fontbuild script if there is an update."
fi

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
fi

# run manual configuration script for
# ~/.config/hypr/land/autostart.conf
# ~/.config/hypr/land/monitors.conf
# ~/.config/hypr/hyprlock.conf
# ~/.config/hypr/hyprpaper.conf
cd "$root"
python3 "$root/settings.py"

# reload to apply the changes made if applicable
[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprctl reload > /dev/null

# print system info to look cool
echo
fastfetch

# final instruction
echo -e "\e[93mReboot to apply all changes.\e[0m"
