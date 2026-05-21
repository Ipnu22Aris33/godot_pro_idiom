extends Node2D

const BLOCK_SCENE = preload("res://scenes/Block.tscn")
const CHUNK_SIZE = 16

var generator: WorldGenerator

var view_direction: int = Iso.Direction.NORTH

var world_data: Dictionary

# node visual saja
var rendered_blocks: Dictionary = {}

var tile_cache: Dictionary = {}

var _center: int = 16

func _ready() -> void:
	$Blocks.y_sort_enabled = true

func generate(chunk_x: int, chunk_y: int) -> void:
	for x in range(-1, CHUNK_SIZE + 1):
		for y in range(-1, CHUNK_SIZE + 1):
			var wx = x + chunk_x * CHUNK_SIZE
			var wy = y + chunk_y * CHUNK_SIZE

			var tile = generator.get_tile_data(wx, wy)

			tile_cache[Vector2i(wx, wy)] = tile

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var wx = x + chunk_x * CHUNK_SIZE
			var wy = y + chunk_y * CHUNK_SIZE

			render_stack(wx, wy)

func render_stack(x: int, y: int) -> void:
	var tile = tile_cache[Vector2i(x, y)]

	for h in range(tile.height):
		world_data[Vector3i(x, y, h)] = true

		if _is_hidden(x, y, h, tile.height):
			continue

		var depth_from_top = tile.height - h - 1

		var block_type = generator.get_block_type(
			depth_from_top,
			tile.type,
			x,
			y
		)

		place_block(x, y, h, block_type)

func _is_hidden(x: int, y: int, h: int, total_height: int) -> bool:
	if h == total_height - 1:
		return false

	var dirs = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir in dirs:
		var neighbor = tile_cache.get(Vector2i(x + dir.x, y + dir.y))

		if neighbor == null:
			return false

		if neighbor.height <= h:
			return false

	return true

func place_block(x: int, y: int, h: int, type: String) -> void:
	var block = BLOCK_SCENE.instantiate()

	$Blocks.add_child(block)

	block.world_x = x
	block.world_y = y
	block.world_h = h

	block.position = Iso.to_screen(
		Iso.screen_at(x, y, h, view_direction, _center)
	)

	block.z_index = Iso.z_index(
		Iso.screen_at(x, y, h, view_direction, _center)
	)

	block.set_type(type)

	rendered_blocks[Vector3i(x, y, h)] = block

func pick_block(mouse: Vector2):
	var best_block = null
	var best_depth = - INF

	for block in rendered_blocks.values():
		var rect = Rect2(
			block.global_position - Vector2(Iso.BLOCK_W / 2, Iso.BLOCK_H / 2),
			Vector2(Iso.BLOCK_W, Iso.BLOCK_H)
		)

		if not rect.has_point(mouse):
			continue

		var above = Vector3i(
			block.world_x,
			block.world_y,
			block.world_h + 1
		)

		if world_data.has(above):
			continue

		var depth = (
			block.world_x +
			block.world_y +
			block.world_h
		)

		if depth > best_depth:
			best_depth = depth
			best_block = block

	return best_block

func break_block(x: int, y: int, h: int) -> bool:
	var key = Vector3i(x, y, h)

	if not world_data.has(key):
		return false

	world_data.erase(key)

	_remove_rendered_block(x, y, h)

	_reveal_block_below(x, y, h)

	return true

func _remove_rendered_block(x: int, y: int, h: int) -> void:
	var key = Vector3i(x, y, h)

	var node = rendered_blocks.get(key)

	if node == null:
		return

	rendered_blocks.erase(key)

	node.queue_free()

func _reveal_block_below(x: int, y: int, h: int) -> void:
	var below_h = h - 1

	if below_h < 0:
		return

	var below_key = Vector3i(x, y, below_h)

	if not world_data.has(below_key):
		return

	if rendered_blocks.has(below_key):
		return

	var tile = tile_cache.get(Vector2i(x, y))

	if tile == null:
		return

	var depth_from_top = tile.height - below_h - 1

	var type = generator.get_block_type(
		depth_from_top,
		tile.type,
		x,
		y
	)

	place_block(x, y, below_h, type)

func update_view(dir: int) -> void:
	view_direction = dir

	for block in rendered_blocks.values():
		block.position = Iso.to_screen(
			Iso.screen_at(
				block.world_x,
				block.world_y,
				block.world_h,
				dir,
				_center
			)
		)

		block.z_index = Iso.z_index(
			Iso.screen_at(
				block.world_x,
				block.world_y,
				block.world_h,
				dir,
				_center
			)
		)