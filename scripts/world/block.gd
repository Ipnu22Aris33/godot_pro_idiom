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
