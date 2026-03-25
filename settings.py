import os
import subprocess

def get_autostart_conf(enabled):
	s = ["" if x else "# " for x in enabled]
	with open("./templates/autostart.txt") as f:
		template = f.read()
	return template.format(*s)

def get_monitors():
	result = subprocess.run(
		["modetest", "-c"],
		capture_output=True,
		text=True,
	)
	output = result.stdout
	monitors = {}
	find_idx = 0
	while True:
		start = output.find("connected", find_idx)
		end = output.find("props:", start)
		find_idx = end
		if find_idx == -1:
			break
		s = output[start : end]
		lines = [l.split() for l in s.split("\n")]
		if len(lines) <= 2:
			continue
		name = lines[0][1]
		modes = []
		for i in range(3, len(lines) - 1):
			modes.append(f"{lines[i][3]}x{lines[i][7]}@{lines[i][2]}")
		monitors[name] = modes
	return monitors

def get_hyprlock_conf(monitors, primary):
	with open("./templates/hyprlock.txt") as f:
		template = f.read()
	with open("./templates/hyprlock_bg_block.txt") as f:
		bg_template = f.read()

	bg_block = ""
	for name, mode in monitors:
		res = mode.split("@")[0]
		bg_block += bg_template\
			.replace("NAME", name)\
			.replace("RESOLUTION", res)
	return template\
		.replace("BG_BLOCK", bg_block)\
		.replace("PRIMARY", primary)

def get_hyprpaper_conf(monitors):
	with open("./templates/hyprpaper.txt") as f:
		template = f.read()
	with open("./templates/hyprpaper_bg_block.txt") as f:
		bg_template = f.read()

	bg_block = ""
	for name, mode in monitors:
		res = mode.split("@")[0]
		bg_block += bg_template\
			.replace("NAME", name)\
			.replace("RESOLUTION", res)
	return template.replace("BG_BLOCK", bg_block)

def get_monitors_conf(monitors, primary, positions, scales, workspaces):
	with open("./templates/monitors.txt") as f:
		template = f.read().split("\n")
	monitor_template = template[0] + "\n"
	workspace_template = template[1] + "\n"
	template = "\n".join(template[2:])

	monitor_block = ""
	for i, (name, mode) in enumerate(monitors):
		monitor_block += monitor_template\
			.replace("NAME", name)\
			.replace("MODE", mode)\
			.replace("POSITION", positions[i])\
			.replace("SCALE", scales[i])
	workspace_block = ""
	for i, name in enumerate(workspaces):
		workspace_block += workspace_template\
			.replace("WORKSPACE", str(i))\
			.replace("NAME", name)

	return monitor_block\
		+ workspace_block\
		+ template\
			.replace("PRIMARY", primary)


if __name__ == "__main__":
	en = [False for i in range(4)]
	en[0] = not input("Enable lock on start? [Y/n] ").startswith("n")
	en[1] = not input("Enable idle dim, lock, and sleep? [Y/n] ").startswith("n")
	en[2] = not input("Enable status bar? [Y/n] ").startswith("n")
	en[3] = not input("Enable wallpaper? [Y/n] ").startswith("n")
	with open("./home/config/hypr/land/autostart.conf", "w") as f:
		f.write(get_autostart_conf(en))

	monitors = {}
	for name, modes in get_monitors().items():
		print(f"Select mode for monitor {name}: (default: 1)")
		for i, m in enumerate(modes):
			print(f" {i+1: 4d}: {m}")
		n = input("> ")
		if not n.isdigit():
			n = "1"
		monitors[name] = modes[int(n) - 1]

	monitors = [(n, m) for n, m in monitors.items()]

	print(f"Select primary monitor: (default: 1)")
	for i, (n, m) in enumerate(monitors):
		print(f" {i+1: 4d}: {n}: {m}")
	n = input("> ")
	if not n.isdigit():
		n = "1"
	primary = int(n) - 1
	if primary not in range(len(monitors)):
		primary = 0

	with open("./home/config/hypr/hyprlock.conf", "w") as f:
		f.write(get_hyprlock_conf(monitors, monitors[primary][0]))

	with open("./home/config/hypr/hyprpaper.conf", "w") as f:
		f.write(get_hyprpaper_conf(monitors))

	positions = []
	for i in range(len(monitors)):
		print(f"Set position for monitor {monitors[i][0]}: (format: XxY)")
		print("Suggestions:")
		if i == primary:
			default = "0x0"
			print("    Primary: 0x0")
		else:
			def size(mode):
				return tuple(map(int, mode.split("@")[0].split("x")))
			psize = size(monitors[primary][1])
			msize = size(monitors[i][1])
			print(f"    Left:   {-msize[0]}x{(psize[1] - msize[1]) // 2}")
			print(f"    Right:  {psize[0]}x{(psize[1] - msize[1]) // 2}")
			print(f"    Top:    {(psize[0] - msize[0]) // 2}x{-msize[1]}")
			print(f"    Bottom: {(psize[0] - msize[0]) // 2}x{psize[1]}")
		p = input("> ")
		if p == "":
			p = "0x0"
		try:
			map(int, p.split("x"))
		except:
			p = "0x0"
		positions.append(p)

	scales = []
	for i in range(len(monitors)):
		print(f"Set scale for monitor {monitors[i][0]}: (default: 1)")
		n = input("> ")
		if not n.isdigit():
			n = "1"
		scales.append(n)

	workspaces = []
	for i in range(10 if len(monitors) > 1 else 0):
		print(f"Select monitor for workspace {i + 1}: (default: primary)")
		for i, (n, m) in enumerate(monitors):
			print(f" {i+1: 4d}: {n}: {m}{" (primary)" if i == primary else ""}")
		n = input("> ")
		if not n.isdigit():
			n = primary + 1
		n = int(n) - 1
		if n not in range(len(monitors)):
			n = primary
		workspaces.append(monitors[n][0])

	with open("./home/config/hypr/land/monitors.conf", "w") as f:
		f.write(get_monitors_conf(monitors, monitors[primary][0], positions, scales, workspaces))
