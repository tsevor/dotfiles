-- LOCAL --

local f = io.popen("uname -n")
local hostname = f:read("*l")
f:close()

success, conf = pcall(require, "machines." .. hostname)

-- ENVIRONMENT --

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("DE", "lxde") -- to trick xdg-open
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("PASSWORD_STORE", "gnome-libsecret")
hl.env("ELECTRON_PASSWORD_STORE", "gnome-libsecret")
hl.env("PROTON_ENABLE_WAYLAND", "1")

-- STARTUP --

hl.on("hyprland.start", function ()
	hl.exec_cmd("~/.config/hypr/scripts/portal-reset.sh")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("xhost +si:localuser:root")

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprlock")
	hl.exec_cmd("waybar")
	hl.exec_cmd("mako")

	if success then
		conf.onstart()
	else
		hl.dispatch(hl.dsp.exec_cmd(
			'alacritty -e sh -c "echo -e \\\
\\\\\\x1b[0\\;91mThis machine does not have its own config file.\\\\\\x1b[m\\\\\\n\\\
You may want to create one in:\\\\\\n\\\
~/.config/hypr/machines/' .. hostname .. '.lua\\\\\\n\\\\\\n\\\
Press enter to dismiss...; read"',
			{ float = true, size = "500 200", center = true }
		))
	end
end)

-- GENERAL --

hl.config({
	binds = {
		scroll_event_delay = 0
	},

	general = {
		gaps_in = 8,
		gaps_out = {top = 0, right = 16, bottom = 16, left = 16},
		border_size = 0,
		col = {
			active_border = {colors = {"#77ffccff", "#cc77ffff"}, angle = 135},
			inactive_border = {colors = {"#77ffcc77", "#cc77ff77"}, angle = 135},
		}
	},

	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		border_part_of_window = true,
		blur = {
			enabled = false,
		},
		shadow = {
			enabled = true,
			range = 16,
			render_power = 2,
			color = "#00000088"
		}
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true
	},

	xwayland = {
	  force_zero_scaling = true
	},
})

-- ANIMATIONS --

-- curves

hl.curve("easeInSine", { type = "bezier", points = { { 0.47, 0 }, { 0.745, 0.715 } } })
hl.curve("easeOutSine", { type = "bezier", points = { { 0.39, 0.575 }, { 0.565, 1 } } })
hl.curve("easeInOutSine", { type = "bezier", points = { { 0.37, 0 }, { 0.63, 1 } } })

hl.curve("easeInCirc", { type = "bezier", points = { { 0.55, 0 }, { 1, 0.45 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })

hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.curve("delay", { type = "bezier", points = { { 1, 0 }, { 1, -.2 } } })

-- animations

hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "easeInOutSine" })

hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "easeInOutCirc" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "easeOutCirc", style = "popin 30%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "easeInCirc", style = "popin 30%" })

hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutCirc", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "easeInCirc", style = "slide" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 1, bezier = "easeOutCirc" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "easeInCirc" })

hl.animation({ leaf = "fadePopupsIn", enabled = true, speed = 1, bezier = "easeOutCirc" })
hl.animation({ leaf = "fadePopupsOut", enabled = true, speed = 1, bezier = "easeInCirc" })

hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "easeOutCirc" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "easeInCirc" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutCirc", style = "slidefade 1%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutCirc", style = "slidefade 1%" })

hl.animation({ leaf = "borderangle", enabled = true, speed = 50, bezier = "easeInOutSine", style = "once" })

-- WINDOW RULES --

hl.window_rule({
	match = { class = "immy" },
	float = true,
	no_shadow = true
})

-- INPUT --

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace"
})

-- apps
hl.bind("SUPER + T", hl.dsp.exec_cmd("alacritty"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("pcmanfm"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("pkill wofi || wofi"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("equicord"))
hl.bind("SUPER + G", hl.dsp.exec_cmd("steam"))

hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/bg-picker.sh"))

-- screen
hl.bind("SUPER + S", hl.dsp.exec_cmd("pkill slurp || hyprshot -o $(xdg-user-dir PICTURES)/screenshots -m region"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("pkill slurp || hyprshot -o $(xdg-user-dir PICTURES) -f immy.png -m region; immy $(xdg-user-dir PICTURES)/immy.png"))

hl.bind("SUPER + mouse:274", hl.dsp.exec_cmd("notify-send $(ps -p \"$(hyprctl activewindow -j | jq -r '.pid')\" -o comm=)"))

-- management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + ALT + Q", hl.dsp.window.kill())
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + CTRL + ALT + Q", hl.dsp.exit())
hl.bind("SUPER + CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("shutdown now"))
hl.bind("SUPER + SHIFT + CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("shutdown -r now"))

hl.bind("SUPER + C", hl.dsp.layout("swapsplit"))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo({ action = "toggle" }))

hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "previous" }))

hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + ALT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + ALT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + ALT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + ALT + down",  hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
	hl.bind("SUPER + " .. i % 10, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + ALT + " .. i % 10, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- other
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86PowerOff", hl.dsp.exec_cmd("systemctl poweroff"), { locked = true })
