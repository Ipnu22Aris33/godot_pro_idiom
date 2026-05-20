extends Node2D

const BLOCK_SCENE = preload("res://scenes/Block.tscn")

const CHUNK_SIZE = 16

var generator: WorldGenerator

func _ready():
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

		var block_type = generator.get_block_type(
			depth_from_top,
			tile.type
		)

		place_block(x, y, h, block_type)

func place_block(x: int, y: int, h: int, type: String) -> void:
	var block = BLOCK_SCENE.instantiate()
	block.position = Iso.to_screen(x, y, h)
	block.z_index = Iso.z_index(x, y, h)

	block.set_type(type)

	$Blocks.add_child(block)