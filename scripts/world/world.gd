extends Node2D

const CHUNK_SCENE = preload("res://scenes/Chunk.tscn")

@export var world_seed: int = 0
@export var chunk_range: int = 2

var generator = WorldGenerator.new()
var view_direction: int = Iso.Direction.NORTH

func _ready() -> void:
	var active_seed = world_seed if world_seed != 0 else randi()
	print("World Seed: ", active_seed)
	generator.setup(active_seed)
	generate_world()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			view_direction = (view_direction + 1) % 4
			_update_view()
		elif event.keycode == KEY_Q:
			view_direction = (view_direction - 1 + 4) % 4
			_update_view()

func _update_view() -> void:
	for chunk in $Chunks.get_children():
		chunk.update_view(view_direction)

func generate_world() -> void:
	var center = (chunk_range * 16.0) / 2
	for x in range(chunk_range):
		for y in range(chunk_range):
			spawn_chunk(x, y, center)

func regenerate_world() -> void:
	for chunk in $Chunks.get_children():
		chunk.queue_free()
	generate_world()

func spawn_chunk(chunk_x: int, chunk_y: int, center: int) -> void:
	var chunk = CHUNK_SCENE.instantiate()
	chunk.generator = generator
	chunk.view_direction = view_direction
	chunk._center = center
	$Chunks.add_child(chunk)
	chunk.generate(chunk_x, chunk_y)
