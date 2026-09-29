-- STARTUP --

function onstart()
	hl.exec_cmd("xrandr --output eDP-1 --primary")


	hl.exec_cmd(
	'alacritty -e sh -c "fastfetch;bash"',
		{ float = true, size = "1200 600", move = { 16, 38 } }
	)

	hl.exec_cmd(
	'immy ~/.config/hypr/images/elgato.png',
		{ float = true, move = { 1354, 184 } }
	)
end

-- MONITOR --

hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = "1"
})

for i = 1, 10 do
	local mon = (i <= 5) and "eDP-1" or "HDMI-A-1"
	hl.workspace_rule({ workspace = tostring(i), monitor = mon })
end

-- RETURN --

return {
	onstart = onstart
}
