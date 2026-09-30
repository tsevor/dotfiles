#!/usr/bin/env bash
set -e

root=$(realpath "$(dirname "$0")")
cd "$root"

printstat() { echo -e "\e[92m$@\e[m"; }

printstat allowing the rest of the script to run without prompting for sudo again
sudo -v
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup_bypass > /dev/null
cleanup() {
	sudo rm -f /etc/sudoers.d/setup_bypass
}
trap cleanup EXIT

printstat making some directories for stuff to land in
mkdir -p "$HOME/.config"
mkdir -p "$HOME/dev"

printstat linking config dirs and files
cfgdirs=(
	alacritty fastfetch fontconfig gtk-3.0 gtk-4.0 hypr micro
	qt5ct qt6ct waybar wofi xarchiver xdg-desktop-portal
	xsettingsd zed mimeapps.list user-dirs.dirs
)

for dir in "${cfgdirs[@]}"; do
	rm -rf "$HOME/.config/$dir"
	ln -s "$root/home/config/$dir" "$HOME/.config/$dir"
done

rcfiles=(
	bashrc bash_aliases bash_profile gtkrc-2.0
)

for file in "${rcfiles[@]}"; do
	ln -sTf "$root/home/$file" "$HOME/.$file"
done

cd "$HOME/dev"
if ! pacman -Qq | grep yay > /dev/null
then
	printstat installing yay
	sudo pacman -S --needed --noconfirm git base-devel
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
fi

cd "$root"

printstat installing packages from packages.txt
sudo pacman -Syu --needed --noconfirm - < packages.txt 2> /dev/null
printstat installing packages from packages_aur.txt
yay -Syu --needed --noconfirm - < packages_aur.txt 2> /dev/null

printstat creating default folders in home
source "$HOME/.config/user-dirs.dirs"
for var in DESKTOP DOWNLOAD TEMPLATES PUBLICSHARE DOCUMENTS MUSIC PICTURES VIDEOS PROJECTS; do
	var_name="XDG_${var}_DIR"
	[ -n "${!var_name}" ] && mkdir -p "${!var_name}"
done
xdg-user-dirs-update

printstat installing service to automatically start hyprland on boot
cat << EOF | sudo systemctl edit --stdin getty@tty1.service
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty -o '-p -f -- \u' --noclear --autologin $USER %I \$TERM
EOF

printstat disabling power button, bound in hyprland config
sudo sed -i 's/^printstat\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

printstat setting gsettings for theming
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'monospace 12'

printstat enabling services
systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon
sudo systemctl enable bluetooth cups.socket udisks2.service

if [ ! -d "$HOME/.config/zen" ]
then
	printstat configuring zen to make it look nicer and function better
	zen-browser -CreateProfile "default $HOME/.config/zen/default"
	zen-browser --headless -P "default" --screenshot /dev/null &> /dev/null

	# symlink zen config
	mkdir -p "$HOME/.config/zen/default/chrome"
	ln -sTf "$root/home/config/zen/user.js" "$HOME/.config/zen/default/user.js"
	ln -sTf "$root/home/config/zen/userChrome.css" "$HOME/.config/zen/default/chrome/userChrome.css"
	ln -sTf "$root/home/config/zen/userContent.css" "$HOME/.config/zen/default/chrome/userContent.css"
fi

cd "$HOME/dev"

for app in immy restart; do
	if [ ! -d "$app" ]; then
		printstat installing $app
		git clone "https://github.com/ztchary/$app"
		cd "$app" || exit 1
		make "$app"
		sudo make install
		cd ..
	else
		printstat updating $app
		cd "$app" || exit 1
		old_hash=$(git rev-parse HEAD)
		git pull --quiet
		new_hash=$(git rev-parse HEAD)
		if [ "\(old_hash" != "\)new_hash" ]; then
			make "$app"
			sudo make install
		fi
		cd ..
	fi
done

cd "$root"

if [ ! -d /usr/share/fonts/wf ]
then
	printstat installing windows fonts
	[ ! -d ./winfonts ] && git clone https://github.com/vhdsih/fonts winfonts
	sudo install -Dm644 winfonts/wf/* -t /usr/share/fonts/wf
	sudo fc-cache -fv
fi

if [ ! -f /usr/share/fonts/TTF/OverpassMonoNerdFont-Regular.ttf ]
then
	printstat manually installing evil hardcoded custom nerd font
	./fontbuild/build.sh
else
	printstat maybe check if the nerd font needs updating
fi

cd "$root"

printstat downloading background images
mkdir -p "$HOME/.config/hypr/images/bg"
wget https://ztchary.net/bg.tar.gz
tar -xzf bg.tar.gz -C "$HOME/.config/hypr/images/bg/"
rm bg.tar.gz

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]
then
	printstat reloading hyprland
	hyprctl reload
fi

printstat printing system info to look cool
echo
fastfetch

echo -e "\e[93myou may need to reboot to apply all changes\e[0m"
