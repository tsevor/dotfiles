[[ -f ~/.bashrc ]] && . ~/.bashrc

tty | grep -q tty1 && exec nice -n -10 start-hyprland
