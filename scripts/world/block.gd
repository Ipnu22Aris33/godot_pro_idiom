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
	
	# Top face diamond
	var points = PackedVector2Array([
		Vector2(0, -hh),
		Vector2(hw, 0),
		Vector2(0, hh),
		Vector2(-hw, 0),
		Vector2(0, -hh),
	])
	draw_polyline(points, Color.RED, 2.0)
	
	# Front face
	draw_rect(
    Rect2(Vector2(-hw, hh), Vector2(Iso.BLOCK_W, Iso.BLOCK_Z)),
    Color.YELLOW, false, 2.0
	)

func set_hovered(value: bool) -> void:
	hovered = value
	sprite.modulate = Color(1.3, 1.3, 1.3) if hovered else Color.WHITE
	queue_redraw()