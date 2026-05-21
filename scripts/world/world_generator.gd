extends RefCounted
class_name WorldGenerator

const HEIGHT_MIN = 5
const HEIGHT_MAX = 50

var noises: Dictionary = {}

func setup(p_seed: int) -> void:
	noises = {
		"continent": _make_noise(p_seed, 0.008, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 6),
		"terrain": _make_noise(p_seed + 100, 0.035, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 4),
		"roughness": _make_noise(p_seed + 200, 0.12, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"flat": _make_noise(p_seed + 400, 0.045, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"mountain": _make_noise(p_seed + 500, 0.018, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_RIDGED, 5),
		"scatter": _make_noise(p_seed + 600, 0.09, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_NONE, 1),
	}

# ─────────────────────────────────────────────
#  TILE DATA
# ─────────────────────────────────────────────
func get_tile_data(x: int, y: int) -> Dictionary:
	var height = get_height(x, y)
	var type = get_surface_type(x, y, height)
	return {"height": height, "type": type}

func get_surface_type(x: int, y: int, height: int) -> String:
	var mountain = sample("mountain", x, y)
	var scatter = sample("scatter", x, y)
	var h_norm = float(height - HEIGHT_MIN) / float(HEIGHT_MAX - HEIGHT_MIN) # 0.0 – 1.0

	# Mountain — tile tinggi dengan noise mountain kuat
	var mountain_threshold = lerp(0.95, 0.6, h_norm)
	if mountain > mountain_threshold:
		return "mountain"

	# Beach — hanya di 15% bawah height range, dan scatter mendukung
	if h_norm < 0.15 and scatter > 0.45:
		return "beach"

	return "grass"

func get_block_type(depth_from_top: int, surface: String, x: int, y: int) -> String:
	match surface:
		"mountain":
			return "stone"

		"beach":
			var sand_depth = 1 + int(sample("scatter", x, y) * 3.0)
			if depth_from_top <= sand_depth:
				return "sand"
			return "stone"

		"grass":
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

	# Base dari continent — 0.0–1.0 di-scale ke HEIGHT_MIN–HEIGHT_MAX
	var h = lerp(float(HEIGHT_MIN), float(HEIGHT_MAX) * 0.5, continent)

	# Detail terrain
	h += terrain * roughness * float(HEIGHT_MAX) * 0.2

	# Flatten
	var flat_target = float(HEIGHT_MAX) * 0.25
	var flat_w = clamp((flatness - 0.55) * 4.0, 0.0, 1.0)
	h = lerp(h, flat_target, flat_w * 0.6)

	# Mountain boost
	var mountain_w = clamp((mountain - 0.6) * 5.0, 0.0, 1.0)
	h += mountain_w * float(HEIGHT_MAX) * 0.5

	return int(round(clamp(h, float(HEIGHT_MIN), float(HEIGHT_MAX))))

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