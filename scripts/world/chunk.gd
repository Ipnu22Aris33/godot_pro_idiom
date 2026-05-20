extends Node2D

const BLOCK_SCENE = preload("res://scenes/Block.tscn")
const CHUNK_SIZE = 16

var generator: WorldGenerator
var view_direction: int = Iso.Direction.NORTH
var _center: int = 16

func _ready() -> void:
	$Blocks.y_sort_enabled = true

func generate(chunk_x: int, chunk_y: int) -> void:
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var wx = x + chunk_x * CHUNK_SIZE
			var wy = y + chunk_y * CHUNK_SIZE
			var tile = generator.get_tile_data(wx, wy)
			render_stack(wx, wy, tile)

func render_stack(x: int, y: int, tile: Dictionary) -> void:
	var total_height = tile.height
	for h in range(total_height):
		var depth_from_top = total_height - h - 1
		var block_type = generator.get_block_type(depth_from_top, tile.type, x, y)
		place_block(x, y, h, block_type)

func place_block(x: int, y: int, h: int, type: String) -> void:
	var block = BLOCK_SCENE.instantiate()
	$Blocks.add_child(block)
	block.world_x = x
	block.world_y = y
	block.world_h = h
	block.position = Iso.to_screen(x, y, h, view_direction, _center)
	block.z_index = Iso.z_index(x, y, h, view_direction, _center)
	block.set_type(type)

func update_view(dir: int) -> void:
	view_direction = dir
	for block_node in $Blocks.get_children():
		block_node.position = Iso.to_screen(block_node.world_x, block_node.world_y, block_node.world_h, dir, _center)
		block_node.z_index = Iso.z_index(block_node.world_x, block_node.world_y, block_node.world_h, dir, _center)
