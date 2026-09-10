-- STARTUP --

function onstart()
	hl.exec_cmd("xrandr --output eDP-1 --primary")
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
