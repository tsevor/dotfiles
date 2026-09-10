-- STARTUP --

function onstart()
	hl.exec_cmd("xrandr --output eDP-1 --primary")


	hl.dispatch(hl.dsp.exec_cmd(
	'alacritty -e sh -c "fastfetch;read"',
		{ float = true, size = "1200 600", move = { 16, 45 } }
	))

	hl.dispatch(hl.dsp.exec_cmd(
	'immy ~/.config/hypr/images/elgato.png',
		{ float = true, move = { 1354, 184 } }
	))
end

-- MONITOR --

hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@240",
	position = "0x0",
	scale = "1"
})

-- RETURN --

return {
	onstart = onstart
}
