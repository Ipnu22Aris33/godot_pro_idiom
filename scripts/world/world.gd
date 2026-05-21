extends Node2D

const CHUNK_SCENE = preload("res://scenes/Chunk.tscn")

@export var world_seed: int = 0
@export var chunk_range: int = 2

var hovered_block: Block = null
var view_direction: int = Iso.Direction.NORTH

func _ready() -> void:
	add_to_group("world")
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

	chunk.view_direction = view_direction
	chunk._center = center

	$Chunks.add_child(chunk)

	chunk.generate(chunk_x, chunk_y)

func _update_view() -> void:
	for chunk in $Chunks.get_children():
		chunk.view_direction = view_direction
		chunk.rebuild()

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

	var blocks: Array[Block] = []

	# ==================================================
	# KUMPULKAN SEMUA BLOCK
	# ==================================================

	for chunk in $Chunks.get_children():
		for block in chunk.rendered_blocks.values():
			blocks.append(block)

	# ==================================================
	# SORT PALING DEPAN DULU
	# ==================================================

	blocks.sort_custom(func(a: Block, b: Block):
		return a.z_index > b.z_index
	)

	# ==================================================
	# CEK SATU-SATU
	# BLOCK DEPAN MENANG TOTAL
	# ==================================================

	var found: Block = null

	for block in blocks:
		if _get_hit_type(mouse, block) != 0:
			found = block
			break

	# ==================================================
	# UPDATE HOVER
	# ==================================================

	if hovered_block == found:
		return

	if hovered_block:
		hovered_block.set_hovered(false)

	hovered_block = found

	if hovered_block:
		hovered_block.set_hovered(true)

# ==================================================
# HIT TEST
# ==================================================

# Return:
# 0 = miss
# 1 = top face
# 2 = side face
func _get_hit_type(mouse: Vector2, block: Block) -> int:
	var pos = block.global_position

	var hw = Iso.BLOCK_W / 2.0
	var hh = Iso.BLOCK_H / 2.0
	var bz = Iso.BLOCK_Z

	var top_y = -bz / 2.0

	# ==================================================
	# LEFT FACE
	# ==================================================

	var left_poly = PackedVector2Array([
		pos + Vector2(-hw, top_y),
		pos + Vector2(0, top_y + hh),
		pos + Vector2(0, top_y + hh + bz),
		pos + Vector2(-hw, top_y + bz)
	])

	if Geometry2D.is_point_in_polygon(mouse, left_poly):
		return 2

	# ==================================================
	# RIGHT FACE
	# ==================================================

	var right_poly = PackedVector2Array([
		pos + Vector2(0, top_y + hh),
		pos + Vector2(hw, top_y),
		pos + Vector2(hw, top_y + bz),
		pos + Vector2(0, top_y + hh + bz)
	])

	if Geometry2D.is_point_in_polygon(mouse, right_poly):
		return 2

	# ==================================================
	# TOP FACE
	# ==================================================

	var top_poly = PackedVector2Array([
		pos + Vector2(0, top_y - hh),
		pos + Vector2(hw, top_y),
		pos + Vector2(0, top_y + hh),
		pos + Vector2(-hw, top_y),
	])

	if Geometry2D.is_point_in_polygon(mouse, top_poly):
		return 1

	return 0

func _block_exists(key: Vector3i) -> bool:
	for chunk in $Chunks.get_children():
		if chunk.rendered_blocks.has(key):
			return true

	return false