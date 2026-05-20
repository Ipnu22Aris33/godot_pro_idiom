extends Node2D

const CHUNK_SCENE = preload("res://scenes/Chunk.tscn")

@export var world_seed: int = 0
@export var chunk_range: int = 2

var noises: Dictionary = {}
var active_seed: int = 0

func _ready():
	generate_world()

func generate_world() -> void:
	active_seed = world_seed if world_seed != 0 else randi()
	print("World seed: ", active_seed)

	_setup_noises(active_seed)

	for x in range(chunk_range):
		for y in range(chunk_range):
			_spawn_chunk(x, y)

func regenerate_world() -> void:
	for child in $Chunks.get_children():
		child.queue_free()
	generate_world()

func _spawn_chunk(chunk_x: int, chunk_y: int) -> void:
	var chunk = CHUNK_SCENE.instantiate()
	chunk.noises = noises
	add_child(chunk)
	chunk.generate(chunk_x, chunk_y)

func _setup_noises(s: int) -> void:
	noises = {
		"continent": _make_noise(s, 0.008, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 6),
		"terrain": _make_noise(s + 100, 0.035, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_FBM, 4),
		"roughness": _make_noise(s + 200, 0.12, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"river": _make_noise(s + 300, 0.022, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_NONE, 1),
		"flat": _make_noise(s + 400, 0.045, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_FBM, 3),
		"mountain": _make_noise(s + 500, 0.018, FastNoiseLite.TYPE_SIMPLEX_SMOOTH, FastNoiseLite.FRACTAL_RIDGED, 5),
		"scatter": _make_noise(s + 600, 0.09, FastNoiseLite.TYPE_PERLIN, FastNoiseLite.FRACTAL_NONE, 1),
	}

func _make_noise(p_seed: int, freq: float, type: int, fractal: int, octaves: int) -> FastNoiseLite:
	var n = FastNoiseLite.new()
	n.seed = p_seed
	n.frequency = freq
	n.noise_type = type
	n.fractal_type = fractal
	n.fractal_octaves = octaves
	return n
