mkdir -p ~/dev
cd ~/dev
sudo pacman -Syu --needed --noconfirm git
git clone https://github.com/tsevor/dotfiles
cd ~/dev/dotfiles
bash ~/dev/dotfiles/setup.sh
