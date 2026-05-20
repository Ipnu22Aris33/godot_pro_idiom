extends Node2D

const BLOCK_SCENE = preload("res://scenes/Block.tscn")
const CHUNK_SIZE = 16

const HEIGHT_RIVER = 9
const HEIGHT_BEACH = 11
const HEIGHT_FLAT = 16
const HEIGHT_HILL = 22
const HEIGHT_MOUNTAIN = 28
const HEIGHT_PEAK = 35

const SURFACE_LAYERS = [
	{"depth": 0, "type": "grass"},
	{"depth": 3, "type": "dirt"},
	{"depth": 999, "type": "stone"},
]

var noises: Dictionary = {}

func _ready():
	$Blocks.y_sort_enabled = true

# ─────────────────────────────────────────────
#  GENERATE — router utama
# ─────────────────────────────────────────────
func generate(chunk_x: int, chunk_y: int) -> void:
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var wx = x + chunk_x * CHUNK_SIZE
			var wy = y + chunk_y * CHUNK_SIZE
			_spawn_tile(wx, wy)

func _spawn_tile(x: int, y: int) -> void:
	# Urutan prioritas terrain — pertama cocok langsung spawn
	if is_river(x, y):
		spawn_river(x, y)
	elif _is_mountain_area(x, y):
		spawn_mountain(x, y)
	elif _is_beach_area(x, y):
		spawn_beach(x, y)
	else:
		spawn_flat(x, y)

# ─────────────────────────────────────────────
#  NOISE SAMPLERS — return 0.0 – 1.0
# ─────────────────────────────────────────────
func sample_continent(x: int, y: int) -> float:
	return (noises["continent"].get_noise_2d(x, y) + 1.0) * 0.5

func sample_terrain(x: int, y: int) -> float:
	return (noises["terrain"].get_noise_2d(x, y) + 1.0) * 0.5

func sample_roughness(x: int, y: int) -> float:
	return (noises["roughness"].get_noise_2d(x, y) + 1.0) * 0.5

func sample_flatness(x: int, y: int) -> float:
	return (noises["flat"].get_noise_2d(x, y) + 1.0) * 0.5

func sample_mountain(x: int, y: int) -> float:
	return (noises["mountain"].get_noise_2d(x, y) + 1.0) * 0.5

func sample_scatter(x: int, y: int) -> float:
	return (noises["scatter"].get_noise_2d(x, y) + 1.0) * 0.5

func is_river(x: int, y: int) -> bool:
	return abs(noises["river"].get_noise_2d(x, y)) < 0.08

# ─────────────────────────────────────────────
#  TERRAIN CLASSIFIERS
# ─────────────────────────────────────────────
func _get_base_height(x: int, y: int) -> int:
	var continent = sample_continent(x, y)
	var terrain = sample_terrain(x, y)
	var roughness = sample_roughness(x, y)
	var flatness = sample_flatness(x, y)
	var mountain = sample_mountain(x, y)

	var h = continent * 14.0 + 4.0
	h += terrain * roughness * 8.0

	var flat_w = clamp((flatness - 0.55) * 4.0, 0.0, 1.0)
	h = lerp(h, float(HEIGHT_FLAT), flat_w * 0.6)

	var mountain_w = clamp((mountain - 0.6) * 5.0, 0.0, 1.0)
	h += mountain_w * 14.0

	return int(round(clamp(h, 5.0, HEIGHT_PEAK)))

func _is_mountain_area(x: int, y: int) -> bool:
	return sample_mountain(x, y) > 0.6 and _get_base_height(x, y) >= HEIGHT_MOUNTAIN

func _is_beach_area(x: int, y: int) -> bool:
	var h = _get_base_height(x, y)
	var scatter = sample_scatter(x, y)
	if h <= HEIGHT_BEACH and scatter > 0.72:
		return true
	if _has_river_neighbor(x, y) and h <= HEIGHT_BEACH + 1 and scatter > 0.3:
		return true
	return false

func _has_river_neighbor(x: int, y: int) -> bool:
	return (
		is_river(x + 1, y) or is_river(x - 1, y) or
		is_river(x, y + 1) or is_river(x, y - 1)
	)

# ─────────────────────────────────────────────
#  SPAWN FUNCTIONS — satu per terrain type
# ─────────────────────────────────────────────
func spawn_flat(x: int, y: int) -> void:
	var h = _get_base_height(x, y)
	_render_stack(x, y, h, func(depth): return _default_surface(depth))

func spawn_beach(x: int, y: int) -> void:
	var h = _get_base_height(x, y)
	_render_stack(x, y, h, func(depth):
		if depth == 0: return "sand"
		if depth <= 2: return "sand"
		return "stone"
	)

func spawn_river(_x: int, _y: int) -> void:
	# Water flat tile — tidak pakai stack tinggi
	pass

func spawn_mountain(x: int, y: int) -> void:
	var h = _get_base_height(x, y)
	_render_stack(x, y, h, func(depth):
		if depth == 0: return "stone" # puncak batu
		return "stone"
		# uncomment kalau sudah ada snow:
		# if depth == 0 and h >= HEIGHT_PEAK - 3: return "snow"
	)

func spawn_sea(x: int, y: int) -> void:
	# Placeholder — pakai kalau ada ocean/sea detection nanti
	_place_block(x, y, HEIGHT_RIVER - 2, HEIGHT_RIVER - 2, "water")

func spawn_cave(x: int, y: int) -> void:
	# Placeholder — pakai kalau ada cave generation nanti
	# Ide: render stack normal tapi skip beberapa layer tengah
	var h = _get_base_height(x, y)
	_render_stack(x, y, h, func(depth):
		return _default_surface(depth)
	)

# ─────────────────────────────────────────────
#  RENDER HELPERS
# ─────────────────────────────────────────────
func _default_surface(depth_from_top: int) -> String:
	for layer in SURFACE_LAYERS:
		if depth_from_top <= layer["depth"]:
			return layer["type"]
	return "stone"

func _render_stack(x: int, y: int, total_height: int, type_fn: Callable) -> void:
	for h in range(total_height):
		var depth_from_top = total_height - h - 1
		_place_block(x, y, h, total_height, type_fn.call(depth_from_top))

func _place_block(x: int, y: int, h: int, _total: int, type: String) -> void:
	var block = BLOCK_SCENE.instantiate()
	block.position = Vector2(
		(x - y) * (Block.TILE_WIDTH / 2.0),
		(x + y) * (Block.TILE_HEIGHT / 2.0) - h * Block.BLOCK_HEIGHT
	)
	block.z_index = h
	block.set_type(type)
	$Blocks.add_child(block)
