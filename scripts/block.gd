class_name Block
extends Node2D

@onready var sprite = $AnimatedSprite2D

# Konstanta ukuran block
const TILE_WIDTH = 32
const TILE_HEIGHT = 16
const BLOCK_HEIGHT = 16


func set_type(type):
	await ready
	if not sprite:
		print("Error: AnimatedSprite2D not found in Block scene!")
		return


	match type:
		"grass":
			sprite.play("grass")
		"dirt":
			sprite.play("dirt")
		"stone":
			sprite.play("stone")
		"water":
			sprite.play("water")
		"sand":
			sprite.play("sand")

# Optional: function untuk mendapatkan ukuran
func get_tile_width():
	return TILE_WIDTH

func get_tile_height():
	return TILE_HEIGHT

func get_block_height():
	return BLOCK_HEIGHT
