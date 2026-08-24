hl.window_rule({
	match = { class = "immy" },
	float = true,
	no_blur = true
})

hl.window_rule({
	match = {
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true
})
