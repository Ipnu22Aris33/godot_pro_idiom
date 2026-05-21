class_name Block
extends Area2D

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

var world: Node = null

func _ready() -> void:
	input_pickable = true

	sprite.region_enabled = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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

func _on_mouse_entered() -> void:
	sprite.modulate = Color(1.3, 1.3, 1.3)

	if world:
		world.hovered_block = self

func _on_mouse_exited() -> void:
	sprite.modulate = Color.WHITE

	if world and world.hovered_block == self:
		world.hovered_block = null