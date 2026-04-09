import fontforge
import math
import sys

if len(sys.argv) != 4:
	print("Usage: fontforge -lang=py -script resize.py <original_ttf> <patched_ttf> <output_ttf>")
	sys.exit(1)

orig_path = sys.argv[1]
patched_path = sys.argv[2]
out_path = sys.argv[3]

orig = fontforge.open(orig_path)
font = fontforge.open(patched_path)

base_width = orig["A"].width
print(f"Base width: {base_width}")

font.os2_winascent = orig.os2_winascent
font.os2_windescent = orig.os2_windescent
font.os2_typoascent = orig.os2_typoascent
font.os2_typodescent = orig.os2_typodescent
font.os2_typolinegap = orig.os2_typolinegap
font.hhea_ascent = orig.hhea_ascent
font.hhea_descent = orig.hhea_descent
font.hhea_linegap = orig.hhea_linegap

tolerance = base_width * 0.10

for glyph in font.glyphs():
	bounds = glyph.boundingBox()
	xmax = bounds[2]

	if xmax > base_width:
		columns = max(1, math.ceil((xmax - tolerance) / base_width))
		glyph.width = base_width * columns

font.generate(out_path)
