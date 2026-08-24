hl.config({
	binds = {
		scroll_event_delay = 0
	}
})

hl.bind("SUPER + T", hl.dsp.exec_cmd("alacritty"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("pcmanfm"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("pkill wofi || wofi --show drun"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("equicord"))
hl.bind("SUPER + G", hl.dsp.exec_cmd("steam"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("spotify-launcher"))

hl.bind("SUPER + S", hl.dsp.exec_cmd("pkill slurp || hyprshot -o $(xdg-user-dir PICTURES)/screenshots -m region"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("pkill slurp || hyprshot -o $(xdg-user-dir PICTURES) -f immy.png -m region; immy $(xdg-user-dir PICTURES)/immy.png"))

hl.bind("SUPER + mouse:274", hl.dsp.exec_cmd("notify-send $(ps -p \"$(hyprctl activewindow -j | jq -r '.pid')\" -o comm=)"))

hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + ALT + Q", hl.dsp.window.kill())
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + CTRL + ALT + Q", hl.dsp.exit())
hl.bind("SUPER + CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("shutdown now"))
hl.bind("SUPER + SHIFT + CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("shutdown -r now"))

hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo({ action = "toggle" }))

-- Zoom
hl.bind("SUPER + mouse_down", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor $(hyprctl getoption -j cursor:zoom_factor | jq -r '.float * 1.1'); hyprctl keyword cursor:invisible 1"))
hl.bind("SUPER + mouse_up",   hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1; hyprctl keyword cursor:invisible 0"))

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + arrow keys
hl.bind("SUPER + ALT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + ALT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + ALT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + ALT + j", hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
	-- Switch workspaces with mainMod + [0-9]
	hl.bind("SUPER + " .. i%10, hl.dsp.focus({ workspace = i }))
	-- Move active window to a workspace with mainMod + SHIFT + [0-9]
	hl.bind("SUPER + ALT + " .. i%10, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Power button
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("systemctl poweroff"), { locked = true })
