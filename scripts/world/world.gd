extends Node2D

const CHUNK_SCENE = preload("res://scenes/Chunk.tscn")

@export var world_seed: int = 0
@export var chunk_range: int = 2

var generator = WorldGenerator.new()

var hovered_block: Block = null

var view_direction: int = Iso.Direction.NORTH

func _ready() -> void:
	add_to_group("world")
	var active_seed = world_seed if world_seed != 0 else randi()

	print("World Seed: ", active_seed)

	generator.setup(active_seed)

	generate_world()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				view_direction = (view_direction + 1) % 4
				_update_view()

			KEY_Q:
				view_direction = (view_direction - 1 + 4) % 4
				_update_view()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_break_block()

func generate_world() -> void:
	var center = (chunk_range * 16.0) / 2

	for chunk_x in range(chunk_range):
		for chunk_y in range(chunk_range):
			spawn_chunk(chunk_x, chunk_y, center)

func regenerate_world() -> void:
	for chunk in $Chunks.get_children():
		chunk.queue_free()

	generate_world()

func spawn_chunk(chunk_x: int, chunk_y: int, center: int) -> void:
	var chunk = CHUNK_SCENE.instantiate()
	chunk.generator = generator
	chunk.view_direction = view_direction
	chunk._center = center
	# Tidak pass world_data lagi
	$Chunks.add_child(chunk)
	chunk.generate(chunk_x, chunk_y)

func _update_view() -> void:
	for chunk in $Chunks.get_children():
		chunk.update_view(view_direction)

func _try_break_block() -> void:
	if hovered_block == null:
		print("No hovered block")
		return

	print("Trying break: ", hovered_block.world_x, hovered_block.world_y, hovered_block.world_h)

	var x = hovered_block.world_x
	var y = hovered_block.world_y
	var h = hovered_block.world_h

	for chunk in $Chunks.get_children():
		print("Chunk world_data has key: ", chunk.world_data.has(Vector3i(x, y, h)))
		if chunk.break_block(x, y, h):
			print("Broken!")
			return
