#!/usr/bin/env python3

import subprocess

class Monitor:
	def __init__(self, name, modes):
		self.name: str = name
		self.modes: list[str] = modes
		self.modeidx: int = 0
		self.size: tuple[int, int] = self.updSize()
		self.refresh: float = self.updRefresh()
		self.pos: tuple[int, int] = (0, 0)
		self.scale: float = 1

	def __str__(self) -> str:
		return (
			self.name + "\n"
			+ "modes:\n"
			+ "\n".join([f"    {i}: " + m + f" (current)" if i == self.modeidx else f"    {i}: " + m for i, m in enumerate(self.modes)]) + "\n"
			+ "size: " + str(self.size) + "\n"
			+ "refresh: " + str(self.refresh) + "\n"
			+ "pos: " + str(self.pos) + "\n"
			+ "scale: " + str(self.scale) + "\n"
		)

	def updSize(self) -> tuple[int, int]:
		return tuple(map(int, self.modes[self.modeidx].split("@")[0].split("x")))

	def updRefresh(self) -> float:
		return float(self.modes[self.modeidx].split("@")[1])

	def collide(self, other: Monitor):
		def manhattan(tup):
			return
		push = None
		if other.pos[0] < self.pos[0] < other.pos[0] + other.size[0]:
			thispush = (self.pos[0] < other.pos[0] + other.size[0], 0)
			if push is None or manhattan(thispush) < manhattan(push):
				push = thispush


class Layout:
	def __init__(self):
		self.monitors: list[Monitor] = self.getMonitors()
		self.primaryidx = 0

	def __str__(self) -> str:
		return (
			"layout:\n"
			+ "\n".join([f"(primary)\n{i}: " + str(m) if i == self.primaryidx else f"{i}: " + str(m) for i, m in enumerate(self.monitors)]) + "\n"
		)

	def getMonitors(self):
		output = subprocess.run(
			["modetest", "-c"],
			capture_output=True,
			text=True,
		).stdout
		monitors = []
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
			monitors.append(Monitor(name, modes))
		return monitors


def main():
	layout = Layout()
	print(str(layout))


if __name__ == "__main__":
	main()
