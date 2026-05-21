class_name Iso
extends RefCounted

const BLOCK_W = 32
const BLOCK_H = 16
const BLOCK_Z = 16

enum Direction {NORTH, EAST, SOUTH, WEST}

class ScreenParams:
	var x: int = 0
	var y: int = 0
	var h: int = 0
	var dir: int = Direction.NORTH
	var center: int = 16

static func screen_at(x: int, y: int, h: int, dir: int, center: int) -> ScreenParams:
	var p = ScreenParams.new()
	p.x = x
	p.y = y
	p.h = h
	p.dir = dir
	p.center = center
	return p

static func to_screen(p: ScreenParams) -> Vector2:
	var cx = p.x - p.center
	var cy = p.y - p.center

	var rx = cx
	var ry = cy

	match p.dir:
		Direction.EAST: rx = cy; ry = - cx
		Direction.SOUTH: rx = - cx; ry = - cy
		Direction.WEST: rx = - cy; ry = cx

	rx += p.center
	ry += p.center

	return Vector2(
		(rx - ry) * (BLOCK_W / 2.0),
		(rx + ry) * (BLOCK_H / 2.0) - p.h * BLOCK_Z
	)

static func z_index(p: ScreenParams) -> int:
	var cx = p.x - p.center
	var cy = p.y - p.center

	var rx = cx
	var ry = cy

	match p.dir:
		Direction.EAST: rx = cy; ry = - cx
		Direction.SOUTH: rx = - cx; ry = - cy
		Direction.WEST: rx = - cy; ry = cx

	rx += p.center
	ry += p.center

	return rx + ry + p.h

static func is_in_front(ax: int, ay: int, ah: int, bx: int, by: int, bh: int) -> bool:
	# Di isometric, block lebih depan kalau x+y lebih besar
	# Kalau x+y sama, yang h lebih tinggi yang di depan
	var a_depth = ax + ay
	var b_depth = bx + by
	if a_depth != b_depth:
		return a_depth < b_depth
	return ah > bh
