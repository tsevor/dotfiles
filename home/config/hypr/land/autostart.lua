hl.on("hyprland.start", function ()
	hl.exec_cmd("~/.config/hypr/scripts/portal-reset.sh")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("xhost +si:localuser:root")
	
	hl.exec_cmd("xrandr --output DP-1 --primary")

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprlock")
--	hl.exec_cmd("hypridle")
--	hl.exec_cmd("waybar")
end)
