extends Resource
## Fixed, authored ordering of reusable terrain beats. No random generation.

const BEAT_WIDTH: int = 1024
const WORLD_WIDTH: int = 39936
const ARENA_X: int = 38912
const CAVE_X: int = 18432
const CAVE_FLOOR: int = 1024
const BEATS: Array[StringName] = [
	# Starting Forest: safe run-up, readable steps, first gaps, then a rest.
	&"trail", &"steps", &"gap", &"trail", &"hops", &"trail",
	# Forest Cliffs: ascending shelves, high routes and changes of rhythm.
	&"trail", &"steps", &"high", &"gap", &"ceiling", &"hops",
	&"high", &"gap", &"steps", &"hops", &"high", &"trail",
	# Mossy ledge above the optional Hidden Cave.
	&"trail", &"hops", &"gap", &"trail",
	# Stave Church Vista: recovery, exploration, then the final rune ascent.
	&"trail", &"steps", &"gap", &"trail", &"hops", &"high", &"ceiling", &"trail",
	# The long bridge alternates decks, gaps, stone supports and a boss rest.
	&"bridge", &"gap", &"bridge", &"hops", &"bridge", &"gap", &"bridge", &"trail"
]

const RUNES: Array = [
	[&"forest_bough", Vector2(1536, 352)],
	[&"forest_path", Vector2(5632, 448)],
	[&"cliff_peak", Vector2(8736, 304)],
	[&"cliff_shelves", Vector2(15952, 352)],
	[&"cave_echo", Vector2(18944, 896)],
	[&"cave_vault", Vector2(21040, 992)],
	[&"vista_light", Vector2(28208, 304)]
]

const CHECKPOINTS: Array = [
	["Forest", &"forest", Vector2(3200, 480)],
	["Cliffs", &"cliffs", Vector2(6272, 480)],
	["Ledge", &"ledge", Vector2(11392, 480)],
	["Falls", &"falls", Vector2(17536, 480)],
	["Cave", &"cave", Vector2(18560, 1024)],
	["Vista", &"vista", Vector2(22656, 480)],
	["Pines", &"pines", Vector2(26752, 480)],
	["Church", &"church", Vector2(30464, 480)],
	["Bridge", &"bridge", Vector2(38656, 480)]
]

const ENEMIES: Array = [
	[&"draugr", Vector2(3712, 480)], [&"draugr", Vector2(6784, 480)],
	[&"raven", Vector2(7872, 288)], [&"draugr", Vector2(10048, 480)],
	[&"draugr", Vector2(12160, 480)], [&"raven", Vector2(12832, 192)],
	[&"draugr", Vector2(14848, 384)], [&"raven", Vector2(17164, 288)],
	[&"draugr", Vector2(20352, 480)], [&"draugr", Vector2(20160, 1024)],
	[&"draugr", Vector2(24064, 384)], [&"raven", Vector2(27360, 288)],
	[&"draugr", Vector2(31360, 480)], [&"draugr", Vector2(35456, 480)],
	[&"raven", Vector2(36576, 320)]
]


static func rectangles(kind: StringName) -> Array[Rect2i]:
	match kind:
		&"steps":
			return [Rect2i(0, 30, 64, 12), Rect2i(16, 27, 8, 3), Rect2i(28, 24, 8, 6), Rect2i(42, 27, 8, 3)]
		&"gap":
			return [Rect2i(0, 30, 28, 12), Rect2i(34, 30, 30, 12)]
		&"high":
			return [Rect2i(0, 30, 64, 12), Rect2i(28, 21, 13, 9), Rect2i(47, 26, 6, 4)]
		&"hops":
			return [Rect2i(0, 30, 18, 12), Rect2i(23, 27, 5, 2), Rect2i(34, 24, 6, 2), Rect2i(48, 30, 16, 12)]
		&"ceiling":
			return [Rect2i(0, 30, 64, 12), Rect2i(23, 26, 19, 1)]
		&"bridge":
			return [Rect2i(0, 30, 16, 12), Rect2i(16, 30, 32, 1), Rect2i(48, 30, 16, 12)]
	return [Rect2i(0, 30, 64, 12)]


static func build(terrain: TileMapLayer) -> void:
	for index in BEATS.size():
		for rect in rectangles(BEATS[index]):
			rect.position.x += index * 64
			terrain.fill_platform(rect)
	terrain.fill_platform(Rect2i(ARENA_X / 16, 30, 64, 12))
	terrain.fill_platform(Rect2i(-1, -8, 1, 88))
	terrain.fill_platform(Rect2i(WORLD_WIDTH / 16, -8, 1, 88))
	# Cave occupies a separate lower route, connected by explicit passage zones.
	for index in 3:
		for rect in rectangles(&"steps" if index == 0 else &"trail"):
			rect.position += Vector2i(CAVE_X / 16 + index * 64, 34)
			terrain.fill_platform(rect)
	terrain.fill_platform(Rect2i(CAVE_X / 16 - 1, 49, 194, 1))
	terrain.fill_platform(Rect2i(CAVE_X / 16 - 1, 49, 1, 28))
	terrain.fill_platform(Rect2i(CAVE_X / 16 + 192, 49, 1, 28))


static func section_at(x: float, cave: bool) -> String:
	if cave:
		return "Hidden Cave"
	if x < 6144:
		return "Starting Forest"
	if x < 22528:
		return "Forest Cliffs"
	if x < 30720:
		return "Stave Church Vista"
	return "Troll Bridge"
