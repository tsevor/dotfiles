import subprocess
import os

MONITORS_OUT = "./home/config/hypr/land/monitors.conf"
AUTOSTART_OUT = "./home/config/hypr/land/autostart.conf"
HYPRPAPER_OUT = "./home/config/hypr/hyprpaper.conf"
HYPRLOCK_OUT = "./home/config/hypr/hyprlock.conf"

with open("./templates/disclaimer.txt") as f:
	DISCLAIMER = f.read()

def homepath(path):
    expath = os.path.expanduser(path)
    abspath = os.path.abspath(expath)
    home = os.path.expanduser("~")
    if abspath.startswith(home):
        relpath = "~" + abspath[len(home):]
        return relpath

def get_autostart_conf(enabled):
	paths = [
		"./templates/autostart.conf"
	]
	s = ["" if x else "# " for x in enabled]
	with open(paths[0]) as f:
		template = f.read()
	return DISCLAIMER\
			.replace("{CONFIG_PATH}", " and ".join(map(homepath, paths)))\
		+ template\
			.replace("{ENABLE_LOCK}", s[0])\
			.replace("{ENABLE_IDLE}", s[1])\
			.replace("{ENABLE_STAT}", s[2])\
			.replace("{ENABLE_WALL}", s[3])

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
	paths = [
		"./templates/hyprlock.conf",
		"./templates/hyprlock_bg_block.conf"
	]
	with open(paths[0]) as f:
		template = f.read()
	with open(paths[1]) as f:
		bg_template = f.read()

	bg_block = ""
	for name, mode in monitors:
		res = mode.split("@")[0]
		bg_block += bg_template\
			.replace("{NAME}", name)\
			.replace("{RESOLUTION}", res)
	return DISCLAIMER\
			.replace("{CONFIG_PATH}", " and ".join(map(homepath, paths)))\
		+ template\
			.replace("{BG_BLOCK}", bg_block)\
			.replace("{PRIMARY}", primary)

def get_hyprpaper_conf(monitors):
	paths = [
		"./templates/hyprpaper.conf",
		"./templates/hyprpaper_bg_block.conf"
	]
	with open(paths[0]) as f:
		template = f.read()
	with open(paths[1]) as f:
		bg_template = f.read()

	bg_block = ""
	for name, mode in monitors:
		res = mode.split("@")[0]
		bg_block += bg_template\
			.replace("{NAME}", name)\
			.replace("{RESOLUTION}", res)
	return DISCLAIMER\
			.replace("{CONFIG_PATH}", " and ".join(map(homepath, paths)))\
		+ template\
			.replace("{BG_BLOCK}", bg_block)

def get_monitors_conf(monitors, primary, positions, scales, workspaces):
	paths = [
		"./templates/monitors.conf"
	]
	with open(paths[0]) as f:
		template = f.read().split("\n")
	monitor_template = template[1] + "\n"
	workspace_template = template[2] + "\n"
	template = "\n".join(template[3:])

	monitor_block = ""
	for i, (name, mode) in enumerate(monitors):
		monitor_block += monitor_template\
			.replace("{NAME}", name)\
			.replace("{MODE}", mode)\
			.replace("{POSITION}", positions[i])\
			.replace("{SCALE}", scales[i])
	workspace_block = ""
	for i, name in enumerate(workspaces):
		workspace_block += workspace_template\
			.replace("{WORKSPACE}", str(i + 1))\
			.replace("{NAME}", name)

	return DISCLAIMER\
			.replace("{CONFIG_PATH}", " and ".join(map(homepath, paths)))\
		+ monitor_block\
		+ workspace_block\
		+ template\
			.replace("{PRIMARY}", primary)

def get_input(prompt):
    print(prompt, end="", flush=True)
    with open("/dev/tty", "r") as terminal:
        return terminal.readline().strip()

def main():
	if (
		os.path.isfile(MONITORS_OUT)
		and os.path.isfile(AUTOSTART_OUT)
		and os.path.isfile(HYPRPAPER_OUT)
		and os.path.isfile(HYPRLOCK_OUT)
	):
		print("\x1b[93mGenerated configs already exist.\x1b[0m")
		if not get_input("Configure features and monitors? [y/N] ").startswith("y"):
			exit(0)

	en = [False for i in range(4)]
	en[0] = not get_input("Enable lock on start? [Y/n] ").startswith("n")
	en[1] = not get_input("Enable idle dim, lock, and sleep? [Y/n] ").startswith("n")
	en[2] = not get_input("Enable status bar? [Y/n] ").startswith("n")
	en[3] = not get_input("Enable wallpaper? [Y/n] ").startswith("n")

	with open(AUTOSTART_OUT, "w") as f:
		f.write(get_autostart_conf(en))

	monitors = {}
	for name, modes in get_monitors().items():
		print(f"Select mode for monitor {name}: (default: 1)")
		for i, m in enumerate(modes):
			print(f" {i+1: 4d}: {m}")
		n = get_input("> ")
		if not n.isdigit():
			n = "1"
		monitors[name] = modes[int(n) - 1]

	monitors = [(n, m) for n, m in monitors.items()]

	print(f"Select primary monitor: (default: 1)")
	for i, (n, m) in enumerate(monitors):
		print(f" {i+1: 4d}: {n}: {m}")
	n = get_input("> ")
	if not n.isdigit():
		n = "1"
	primary = int(n) - 1
	if primary not in range(len(monitors)):
		primary = 0

	with open(HYPRLOCK_OUT, "w") as f:
		f.write(get_hyprlock_conf(monitors, monitors[primary][0]))

	with open(HYPRPAPER_OUT, "w") as f:
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
		p = get_input("> ")
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
		n = get_input("> ")
		if not n.isdecimal():
			n = "1"
		scales.append(n)

	workspaces = []
	for i in range(10 if len(monitors) > 1 else 0):
		print(f"Select monitor for workspace {i + 1}: (default: primary)")
		for i, (n, m) in enumerate(monitors):
			print(f" {i+1: 4d}: {n}: {m}{" (primary)" if i == primary else ""}")
		n = get_input("> ")
		if not n.isdigit():
			n = primary + 1
		n = int(n) - 1
		if n not in range(len(monitors)):
			n = primary
		workspaces.append(monitors[n][0])

	with open(MONITORS_OUT, "w") as f:
		f.write(get_monitors_conf(monitors, monitors[primary][0], positions, scales, workspaces))

if __name__ == "__main__":
	main()
