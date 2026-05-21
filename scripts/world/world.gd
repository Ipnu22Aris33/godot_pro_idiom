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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover()

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
	$Chunks.add_child(chunk)
	chunk.generate(chunk_x, chunk_y)

func _update_view() -> void:
	for chunk in $Chunks.get_children():
		chunk.update_view(view_direction)

func _try_break_block() -> void:
	if hovered_block == null:
		return

	var x = hovered_block.world_x
	var y = hovered_block.world_y
	var h = hovered_block.world_h

	for chunk in $Chunks.get_children():
		if chunk.rendered_blocks.has(Vector3i(x, y, h)):
			chunk.break_block(x, y, h)
			return

func _update_hover() -> void:
	var mouse = get_global_mouse_position()
	var best_block: Block = null
	var best_score := -INF

	for chunk in $Chunks.get_children():
		for block in chunk.rendered_blocks.values():
			var hit = _get_hit_type(mouse, block)
			if hit == 0:
				continue

			# x+y besar = lebih kelihatan (render di atas)
			# top face lebih prioritas dari side face
			var score = float(block.world_x + block.world_y)

			if score > best_score:
				best_score = score
				best_block = block

	if hovered_block == best_block:
		return

	if hovered_block:
		hovered_block.set_hovered(false)

	hovered_block = best_block

	if hovered_block:
		hovered_block.set_hovered(true)

# Return: 0 = tidak kena, 1 = top face, 2 = side face
func _get_hit_type(mouse: Vector2, block: Block) -> int:
	var pos = block.global_position

	# Ukuran tile isometric: 32x16
	# Top face = diamond dengan hw=16, hh=8
	var hw = 16.0 # BLOCK_W / 2
	var hh = 8.0 # BLOCK_H / 2
	var bz = 16.0 # BLOCK_Z = tinggi block

	# Top face — diamond di bagian atas sprite
	# Sprite 32x32, top face ada di bagian atas (y 0-16 dari center)
	var top_center = pos + Vector2(0, -bz / 2.0)
	var local = mouse - top_center
	if (abs(local.x) / hw + abs(local.y) / hh) <= 1.0:
		return 1

	# Side face kiri (arah -x) — visible kalau tidak ada block di sebelah kiri
	if not _block_exists(Vector3i(block.world_x - 1, block.world_y, block.world_h)):
		var left_rect = Rect2(
			pos + Vector2(-hw, hh - bz / 2.0),
			Vector2(hw, bz)
		)
		if left_rect.has_point(mouse):
			return 2

	# Side face kanan (arah -y) — visible kalau tidak ada block di sebelah kanan
	if not _block_exists(Vector3i(block.world_x, block.world_y - 1, block.world_h)):
		var right_rect = Rect2(
			pos + Vector2(0, hh - bz / 2.0),
			Vector2(hw, bz)
		)
		if right_rect.has_point(mouse):
			return 2

	return 0

func _block_exists(key: Vector3i) -> bool:
	for chunk in $Chunks.get_children():
		if chunk.rendered_blocks.has(key):
			return true
	return false