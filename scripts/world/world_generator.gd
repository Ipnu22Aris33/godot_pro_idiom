extends RefCounted
class_name WorldGenerator

const HEIGHT_RIVER = 9
const HEIGHT_BEACH = 11
const HEIGHT_FLAT = 16
const HEIGHT_MOUNTAIN = 28
const HEIGHT_PEAK = 35

var noises: Dictionary = {}

func setup(p_seed: int) -> void:
	noises = {
		"continent": _make_noise(p_seed, 0.008, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 6),
		"terrain": _make_noise(p_seed + 100, 0.035, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 4),
		"roughness": _make_noise(p_seed + 200, 0.12, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"river": _make_noise(p_seed + 300, 0.022, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_NONE, 1),
		"flat": _make_noise(p_seed + 400, 0.045, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"mountain": _make_noise(p_seed + 500, 0.018, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_RIDGED, 5),
		"scatter": _make_noise(p_seed + 600, 0.09, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_NONE, 1),
	}

# ─────────────────────────────────────────────
#  TILE DATA
# ─────────────────────────────────────────────
func get_tile_data(x: int, y: int) -> Dictionary:
	if is_river(x, y):
		return {"height": HEIGHT_RIVER, "type": "water"}

	var height = get_height(x, y)

	if is_mountain(x, y, height):
		return {"height": height, "type": "mountain"}

	if is_beach(x, y, height):
		return {"height": height, "type": "beach"}

	return {"height": height, "type": "grass"}

func get_block_type(depth_from_top: int, surface: String, x: int, y: int) -> String:
	match surface:
		"water":
			return "water"

		"beach":
			# sand minimal 1, sisanya random 1–4 berdasarkan scatter
			var sand_depth = 1 + int(sample("scatter", x, y) * 3.0)
			if depth_from_top <= sand_depth:
				return "sand"
			return "stone"

		"mountain":
			return "stone"

		"grass":
			# dirt minimal 1, sisanya random 1–4 berdasarkan scatter
			var dirt_depth = 1 + int(sample("scatter", x, y) * 3.0)
			if depth_from_top == 0:
				return "grass"
			if depth_from_top <= dirt_depth:
				return "dirt"
			return "stone"

	return "stone"

# ─────────────────────────────────────────────
#  HEIGHT
# ─────────────────────────────────────────────
func get_height(x: int, y: int) -> int:
	var continent = sample("continent", x, y)
	var terrain = sample("terrain", x, y)
	var roughness = sample("roughness", x, y)
	var flatness = sample("flat", x, y)
	var mountain = sample("mountain", x, y)

	var h = continent * 14.0 + 4.0
	h += terrain * roughness * 8.0

	var flat_w = clamp((flatness - 0.55) * 4.0, 0.0, 1.0)
	h = lerp(h, float(HEIGHT_FLAT), flat_w * 0.6)

	var mountain_w = clamp((mountain - 0.6) * 5.0, 0.0, 1.0)
	h += mountain_w * 14.0

	return int(round(clamp(h, 5.0, HEIGHT_PEAK)))

# ─────────────────────────────────────────────
#  TERRAIN CLASSIFIERS
# ─────────────────────────────────────────────
func is_river(x: int, y: int) -> bool:
	return abs(noises["river"].get_noise_2d(x, y)) < 0.08

func is_mountain(x: int, y: int, height: int) -> bool:
	return sample("mountain", x, y) > 0.6 and height >= HEIGHT_MOUNTAIN

func is_beach(x: int, y: int, height: int) -> bool:
	var scatter = sample("scatter", x, y)
	if height <= HEIGHT_BEACH and scatter > 0.72:
		return true
	if has_river_neighbor(x, y) and height <= HEIGHT_BEACH + 1 and scatter > 0.3:
		return true
	return false

func has_river_neighbor(x: int, y: int) -> bool:
	return (
		is_river(x + 1, y) or is_river(x - 1, y) or
		is_river(x, y + 1) or is_river(x, y - 1)
	)

# ─────────────────────────────────────────────
#  NOISE HELPERS
# ─────────────────────────────────────────────
func sample(name: String, x: int, y: int) -> float:
	return (noises[name].get_noise_2d(x, y) + 1.0) * 0.5

func _make_noise(p_seed: int, freq: float, type: int, fractal: int, octaves: int) -> FastNoiseLite:
	var n = FastNoiseLite.new()
	n.seed = p_seed
	n.frequency = freq
	n.noise_type = type
	n.fractal_type = fractal
	n.fractal_octaves = octaves
	return n