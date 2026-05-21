class_name Block
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

const SPRITE_SIZE = 32

const TILES = {
	"grass": Vector2i(0, 0),
	"dirt": Vector2i(4, 0),
	"stone": Vector2i(0, 1),
	"sand": Vector2i(2, 0),
	"water": Vector2i(3, 0),
}

var world_x: int = 0
var world_y: int = 0
var world_h: int = 0

var hovered := false

# IMPORTANT
var show_left := true
var show_right := true

func _ready() -> void:
	sprite.region_enabled = true

func set_type(type: String) -> void:
	if not is_inside_tree():
		await tree_entered

	var coord = TILES.get(type, Vector2i(0, 0))

	sprite.region_rect = Rect2(
		coord.x * SPRITE_SIZE,
		coord.y * SPRITE_SIZE,
		SPRITE_SIZE,
		SPRITE_SIZE
	)

func _draw() -> void:
	if not hovered:
		return

	var hw = Iso.BLOCK_W / 2.0
	var hh = Iso.BLOCK_H / 2.0
	var bz = Iso.BLOCK_Z

	var top_y = - bz / 2.0

	# ==================================================
	# TOP FACE
	# ==================================================

	var top_poly = PackedVector2Array([
		Vector2(0, top_y - hh),
		Vector2(hw, top_y),
		Vector2(0, top_y + hh),
		Vector2(-hw, top_y),
	])

	draw_colored_polygon(
		top_poly,
		Color(1, 0, 0, 0.25)
	)

	draw_polyline(
		top_poly + PackedVector2Array([top_poly[0]]),
		Color.RED,
		2.0
	)

	# ==================================================
	# LEFT FACE
	# ==================================================

	if show_left:
		var left_poly = PackedVector2Array([
			Vector2(-hw, top_y),
			Vector2(0, top_y + hh),
			Vector2(0, top_y + hh + bz),
			Vector2(-hw, top_y + bz)
		])

		draw_colored_polygon(
			left_poly,
			Color(0, 1, 0, 0.25)
		)

		draw_polyline(
			left_poly + PackedVector2Array([left_poly[0]]),
			Color.GREEN,
			2.0
		)

	# ==================================================
	# RIGHT FACE
	# ==================================================

	if show_right:
		var right_poly = PackedVector2Array([
			Vector2(0, top_y + hh),
			Vector2(hw, top_y),
			Vector2(hw, top_y + bz),
			Vector2(0, top_y + hh + bz)
		])

		draw_colored_polygon(
			right_poly,
			Color(0, 0.5, 1, 0.25)
		)

		draw_polyline(
			right_poly + PackedVector2Array([right_poly[0]]),
			Color.CYAN,
			2.0
		)

func set_hovered(value: bool) -> void:
	hovered = value
	sprite.modulate = Color(1.3, 1.3, 1.3) if hovered else Color.WHITE
	queue_redraw()