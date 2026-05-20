class_name Iso
extends RefCounted

const BLOCK_W = 32 # lebar block isometric (horizontal)
const BLOCK_H = 16 # tinggi block isometric (vertikal, setengah dari lebar)
const BLOCK_Z = 16 # tinggi block secara depth/elevasi

static func to_screen(x: int, y: int, h: int = 0) -> Vector2:
	return Vector2(
		(x - y) * (BLOCK_W / 2.0),
		(x + y) * (BLOCK_H / 2.0) - h * BLOCK_Z
	)

static func to_world(screen: Vector2) -> Vector2i:
	var x = (screen.x / (BLOCK_W / 2.0) + screen.y / (BLOCK_H / 2.0)) / 2.0
	var y = (screen.y / (BLOCK_H / 2.0) - screen.x / (BLOCK_W / 2.0)) / 2.0
	return Vector2i(int(round(x)), int(round(y)))

static func z_index(x: int, y: int, h: int = 0) -> int:
	return x + y + h