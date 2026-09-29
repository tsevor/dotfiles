#!/usr/bin/env bash
set -e

root=$(realpath "$(dirname "$0")")
cd "$root"

prnstat() { echo -e "\e[92m$@\e[m"; }

prnstat allowing the rest of the script to run without prompting for sudo again
sudo -v
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup_bypass > /dev/null
cleanup() {
	sudo rm -f /etc/sudoers.d/setup_bypass
}
trap cleanup EXIT

prnstat making some directories for stuff to land in
mkdir -p "$HOME/.config"
mkdir -p "$HOME/dev"

prnstat linking config dirs and files
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

prnstat installing yay
cd "$HOME/dev"
if ! pacman -Qq | grep yay
then
	sudo pacman -S --needed --noconfirm git base-devel
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
fi

cd "$root"

prnstat installing packages from packages.txt and packages_aur.txt
sudo pacman -Syu --needed --noconfirm - < packages.txt 2> /dev/null
yay -Syu --needed --noconfirm - < packages_aur.txt

prnstat creating default folders in home
source "$HOME/.config/user-dirs.dirs"
for var in DESKTOP DOWNLOAD TEMPLATES PUBLICSHARE DOCUMENTS MUSIC PICTURES VIDEOS PROJECTS; do
	var_name="XDG_${var}_DIR"
	[ -n "${!var_name}" ] && mkdir -p "${!var_name}"
done
xdg-user-dirs-update

prnstat installing service to automatically start hyprland on boot
cat << EOF | sudo systemctl edit --stdin getty@tty1.service
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty -o '-p -f -- \u' --noclear --autologin $USER %I \$TERM
EOF

prnstat disabling power button, bound in hyprland config
sudo sed -i 's/^prnstat\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

prnstat setting gsettings for theming
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'monospace 12'

prnstat enabling services
systemctl --user enable pipewire pipewire-pulse wireplumber swaync gnome-keyring-daemon
sudo systemctl enable bluetooth cups.socket udisks2.service

prnstat configuring zen to make it look nicer and function better
if [ ! -d "$HOME/.config/zen" ]
then
	zen-browser -CreateProfile "default $HOME/.config/zen/default"

	timeout 10 zen-browser --headless -P "default" --screenshot /dev/null &> /dev/null || true

	cat << 'EOF' > "$HOME/.config/zen/default/user.js"
user_pref("zen.view.experimental-no-window-controls", true);
user_pref("zen.theme.content-element-separation", 0);
user_pref("zen.welcome-screen.seen", true);
user_pref("zen.window-sync.enabled", false);
EOF
fi

prnstat making and installing immy and restart
cd "$HOME/dev"

for app in immy restart; do
	if [ ! -d "$app" ]; then
		git clone "https://github.com/ztchary/$app"
		cd "$app" || exit 1
		make "$app"
		sudo make install
		cd ..
	else
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

prnstat installing windows fonts
if [ ! -d /usr/share/fonts/wf ]
then
	[ ! -d ./winfonts ] && git clone https://github.com/vhdsih/fonts winfonts
	sudo install -Dm644 winfonts/wf/* -t /usr/share/fonts/wf
	sudo fc-cache -fv
fi

prnstat manually installing evil hardcoded custom nerd font
if [ ! -f /usr/share/fonts/TTF/OverpassMonoNerdFont-Regular.ttf ]
then
	./fontbuild/build.sh
else
	echo "Overpass Mono Nerd Font already installed."
	echo "You may need to manually run the fontbuild script if there is an update."
fi

cd "$root"

prnstat downloading background images
mkdir -p "$HOME/.config/hypr/images/bg"
wget https://ztchary.net/bg.tar.gz
tar -xzf bg.tar.gz -C "$HOME/.config/hypr/images/bg/"
rm bg.tar.gz

prnstat reloading hyprland to apply the changes made if applicable
[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprctl reload > /dev/null

prnstat printing system info to look cool
echo
fastfetch

echo -e "\e[93myou may need to reboot to apply all changes\e[0m"
