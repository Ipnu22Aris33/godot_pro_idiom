extends Node2D

const CHUNK_SCENE = preload("res://scenes/Chunk.tscn")


@export var world_seed: int = 0
@export var chunk_range: int = 2

var generator = WorldGenerator.new()

func _ready():
	var active_world_seed: int

	if world_seed != 0:
		active_world_seed = world_seed
	else:
		active_world_seed = randi()

	print("World Seed: ", active_world_seed)

	generator.setup(active_world_seed)

	generate_world()

func generate_world() -> void:
	for x in range(chunk_range):
		for y in range(chunk_range):
			spawn_chunk(x, y)

func spawn_chunk(chunk_x: int, chunk_y: int) -> void:
	var chunk = CHUNK_SCENE.instantiate()

	chunk.generator = generator

	add_child(chunk)

	chunk.generate(chunk_x, chunk_y)