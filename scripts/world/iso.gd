class_name Iso
extends RefCounted

const BLOCK_W = 32
const BLOCK_H = 16
const BLOCK_Z = 16

enum Direction {NORTH, EAST, SOUTH, WEST}

static func to_screen(x: int, y: int, h: int = 0, dir: int = Direction.NORTH, center: int = 16) -> Vector2:
	var cx = x - center
	var cy = y - center

	var rx = cx
	var ry = cy

	match dir:
		Direction.EAST: rx = cy; ry = - cx
		Direction.SOUTH: rx = - cx; ry = - cy
		Direction.WEST: rx = - cy; ry = cx

	rx += center
	ry += center

	return Vector2(
		(rx - ry) * (BLOCK_W / 2.0),
		(rx + ry) * (BLOCK_H / 2.0) - h * BLOCK_Z
	)

static func z_index(x: int, y: int, h: int = 0, dir: int = Direction.NORTH, center: int = 16) -> int:
	var cx = x - center
	var cy = y - center

	var rx = cx
	var ry = cy

	match dir:
		Direction.EAST: rx = cy; ry = - cx
		Direction.SOUTH: rx = - cx; ry = - cy
		Direction.WEST: rx = - cy; ry = cx

	rx += center
	ry += center

	return rx + ry + h

static func to_world(screen: Vector2) -> Vector2i:
	var x = (screen.x / (BLOCK_W / 2.0) + screen.y / (BLOCK_H / 2.0)) / 2.0
	var y = (screen.y / (BLOCK_H / 2.0) - screen.x / (BLOCK_W / 2.0)) / 2.0
	return Vector2i(int(round(x)), int(round(y)))