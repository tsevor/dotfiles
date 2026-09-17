#!/usr/bin/env bash
set -e

root=$(realpath "$(dirname "$0")")
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
rm -rf ~/.config/zed        ; ln -s "$root/home/config/zed"        ~/.config
rm -rf ~/.config/waybar     ; ln -s "$root/home/config/waybar"     ~/.config
rm -rf ~/.config/mako       ; ln -s "$root/home/config/mako"       ~/.config
rm -rf ~/.config/fontconfig ; ln -s "$root/home/config/fontconfig" ~/.config
rm -rf ~/.config/gtk-3.0    ; ln -s "$root/home/config/gtk-3.0"    ~/.config
rm -rf ~/.config/gtk-4.0    ; ln -s "$root/home/config/gtk-4.0"    ~/.config
rm -rf ~/.config/qt5ct      ; ln -s "$root/home/config/qt5ct"      ~/.config
rm -rf ~/.config/qt6ct      ; ln -s "$root/home/config/qt6ct"      ~/.config
rm -rf ~/.config/xarchiver  ; ln -s "$root/home/config/xarchiver"  ~/.config
rm -rf ~/.config/xsettingsd ; ln -s "$root/home/config/xsettingsd" ~/.config
rm -rf ~/.config/xdg-desktop-portal ; ln -s "$root/home/config/xdg-desktop-portal" ~/.config
rm -rf ~/.config/user-dirs.dirs     ; ln -s "$root/home/config/user-dirs.dirs"     ~/.config
rm -rf ~/.config/mimeapps.list      ; ln -s "$root/home/config/mimeapps.list"      ~/.config

# link rc files
rm -f ~/.bashrc             ; ln -s "$root/home/bashrc"            ~/.bashrc
rm -f ~/.bash_aliases       ; ln -s "$root/home/bash_aliases"      ~/.bash_aliases
rm -f ~/.bash_profile       ; ln -s "$root/home/bash_profile"      ~/.bash_profile
rm -f ~/.gtkrc-2.0          ; ln -s "$root/home/gtkrc-2.0"         ~/.gtkrc-2.0

# install yay
cd ~/dev
if ! pacman -Qq | grep yay
then
	sudo pacman -S --needed --noconfirm git base-devel
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
fi

cd "$root"

# install packages from packages.txt and packages_aur.txt
sudo pacman -Syu --needed --noconfirm - < packages.txt
yay -Syu --needed --noconfirm - < packages_aur.txt

# create default folders in home
source ~/.config/user-dirs.dirs
for var in DESKTOP DOWNLOAD TEMPLATES PUBLICSHARE DOCUMENTS MUSIC PICTURES VIDEOS PROJECTS; do
	var_name="XDG_${var}_DIR"
	[ -n "${!var_name}" ] && mkdir -p "${!var_name}"
done
xdg-user-dirs-update

# install service to automatically start hyprland on boot
cat << EOF | sudo systemctl edit --stdin getty@tty1.service
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty -o '-p -f -- \u' --noclear --autologin $USER %I \$TERM
EOF

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
	killall -q zen-bin ||:
	mkdir -p ~/.config/zen

	# make zen default for its supported mime types
	grep -Po '(?<=^MimeType=).*' /usr/share/applications/zen.desktop | \
		tr ';' '\n' | sed '/^$/d' | xargs -I {} xdg-mime default zen.desktop {}
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

# install windows fonts (i'm not distributing these so it's fine)
if [ ! -d /usr/share/fonts/wf ]
then
	[ ! -d ./winfonts ] && git clone https://github.com/vhdsih/fonts winfonts
	sudo install -Dm644 winfonts/wf/* -t /usr/share/fonts/wf
	sudo fc-cache -fv
fi

# evil hardcoded manual install of custom nerd font
if [ ! -f /usr/share/fonts/TTF/OverpassMonoNerdFont-Regular.ttf ]
then
	./fontbuild/build.sh
else
	echo "Overpass Mono Nerd Font already installed."
	echo "You may need to manually run the fontbuild script if there is an update."
fi

cd "$root"

# download background images
mkdir -p ~/.config/hypr/images/bg
wget https://ztchary.net/bg.tar.gz
tar -xzf bg.tar.gz -C ~/.config/hypr/images/bg/
rm bg.tar.gz

# reload to apply the changes made if applicable
[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprctl reload > /dev/null

# print system info to look cool
echo
fastfetch

# final instruction
echo -e "\e[93mReboot to apply all changes.\e[0m"
