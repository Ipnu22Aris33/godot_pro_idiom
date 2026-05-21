extends Node2D

const BLOCK_SCENE = preload(
	"res://scenes/Block.tscn"
)

const CHUNK_SIZE = 16
const STACK_HEIGHT = 5

var rendered_blocks: Dictionary = {}

var view_direction: int = Iso.Direction.NORTH

var _center: int = 16

var chunk_x: int = 0
var chunk_y: int = 0

func _ready() -> void:
	$Blocks.y_sort_enabled = false

func generate(
	cx: int,
	cy: int
) -> void:
	chunk_x = cx
	chunk_y = cy

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var wx = (
				x +
				chunk_x * CHUNK_SIZE
			)

			var wy = (
				y +
				chunk_y * CHUNK_SIZE
			)

			render_stack(wx, wy)

func render_stack(
	x: int,
	y: int
) -> void:
	for h in range(STACK_HEIGHT):
		var block_type := "grass"

		if h < STACK_HEIGHT - 1:
			block_type = "dirt"

		place_block(
			x,
			y,
			h,
			block_type
		)

func place_block(
	x: int,
	y: int,
	h: int,
	type: String
) -> void:
	var block = BLOCK_SCENE.instantiate()

	$Blocks.add_child(block)

	block.world_x = x
	block.world_y = y
	block.world_h = h

	var screen = Iso.screen_at(
		x,
		y,
		h,
		view_direction,
		_center
	)

	block.position = Iso.to_screen(screen)

	block.z_index = Iso.z_index(screen)

	block.set_type(type)

	rendered_blocks[
		Vector3i(x, y, h)
	] = block

func break_block(
	x: int,
	y: int,
	h: int
) -> bool:
	var key = Vector3i(x, y, h)

	if not rendered_blocks.has(key):
		return false

	var block = rendered_blocks[key]

	rendered_blocks.erase(key)

	block.queue_free()

	return true

func rebuild() -> void:
	for block in rendered_blocks.values():
		block.queue_free()

	rendered_blocks.clear()

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var wx = (
				x +
				chunk_x * CHUNK_SIZE
			)

			var wy = (
				y +
				chunk_y * CHUNK_SIZE
			)

			render_stack(wx, wy)