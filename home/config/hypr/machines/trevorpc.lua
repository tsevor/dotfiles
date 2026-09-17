-- STARTUP --

function onstart()
	hl.exec_cmd("xrandr --output DP-1 --primary")


	hl.exec_cmd(
	'alacritty -e sh -c "fastfetch;read"',
		{ float = true, size = "1200 600", move = { 16, 44 } }
	)

	hl.exec_cmd(
	'immy ~/.config/hypr/images/elgato.png',
		{ float = true, move = { 1994, 424 } }
	)
end

-- MONITOR --

hl.monitor({
	output = "DP-1",
	mode = "2560x1440@240",
	position = "0x0",
	scale = "1"
})

-- RETURN --

return {
	onstart = onstart
}
