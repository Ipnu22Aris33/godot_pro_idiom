extends Camera2D

@export var move_speed: float = 400.0
@export var zoom_speed: float = 0.1
@export var zoom_min: float = 0.5
@export var zoom_max: float = 3.0
@export var smoothing: float = 8.0 # makin tinggi makin responsif, makin rendah makin lembut

var _target_pos: Vector2 = Vector2.ZERO
var _target_zoom: Vector2 = Vector2.ONE

func _ready() -> void:
	_target_pos = position
	_target_zoom = zoom

func _process(delta: float) -> void:
	_handle_move(delta)
	# Lerp posisi dan zoom ke target — ini yang bikin smooth
	position = position.lerp(_target_pos, smoothing * delta)
	zoom = zoom.lerp(_target_zoom, smoothing * delta)

func _unhandled_input(event: InputEvent) -> void:
	_handle_zoom(event)

func _handle_move(delta: float) -> void:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S): dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W): dir.y -= 1

	_target_pos += dir.normalized() * move_speed * delta

func _handle_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = clamp(_target_zoom + Vector2.ONE * zoom_speed, Vector2.ONE * zoom_min, Vector2.ONE * zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = clamp(_target_zoom - Vector2.ONE * zoom_speed, Vector2.ONE * zoom_min, Vector2.ONE * zoom_max)