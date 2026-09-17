-- STARTUP --

function onstart()
	hl.exec_cmd("xrandr --output HDMI-A-1 --primary")


	hl.exec_cmd(
	'alacritty -e sh -c "fastfetch;read"',
		{ float = true, size = "1200 600", move = { 16, 44 } }
	)

	hl.exec_cmd(
	'immy ~/.config/hypr/images/elgato.png',
		{ float = true, move = { 1354, 184 } }
	)
end

-- MONITOR --

hl.monitor({
	output = "HDMI-A-1",
	mode = "2560x1440@144",
	position = "0x0",
	scale = "1"
})
hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "2560x0",
	scale = "1"
})

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "7", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "8", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })

-- RETURN --

return {
	onstart = onstart
}
