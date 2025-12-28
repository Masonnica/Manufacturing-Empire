extends Camera3D

@onready var terrain = $"../Game/Terrain"

# ==================================================
# CAMERA TUNING
# ==================================================
@export var move_speed: float = 20.0
@export var rotate_speed: float = 1.5
@export var zoom_speed: float = 20.0

@export var min_height: float = 3.0
@export var max_height: float = 80.0

# ==================================================
# INITIAL STATE
# ==================================================
@export var start_position: Vector3 = Vector3(0, 25, 25)
@export var start_yaw: float = 0.0
@export var tilt_angle: float = -65.0
@export var apply_start_transform: bool = true

# ==================================================
# INTERNAL STATE
# ==================================================
var is_panning: bool = false
var is_rotating: bool = false

var last_mouse_pos: Vector2 = Vector2.ZERO
var zoom_velocity: float = 0.0

# ==================================================
# READY
# ==================================================
func _ready() -> void:
	if apply_start_transform:
		global_position = start_position
		rotation_degrees = Vector3(tilt_angle, start_yaw, 0.0)
		update_global_camera_position()
		update_global_camera_rotation()

# ==================================================
# INPUT
# ==================================================
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event

		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = mb.pressed
			if is_panning:
				last_mouse_pos = mb.position

		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			is_rotating = mb.pressed

		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_velocity -= zoom_speed

		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_velocity += zoom_speed

	elif event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event

		if is_panning:
			pan_screen_space(mm.position)

		elif is_rotating:
			rotate_y(mm.relative.x * 0.002)

# ==================================================
# PROCESS
# ==================================================
func _process(delta: float) -> void:
	update_keyboard_movement(delta)
	update_keyboard_rotation(delta)
	update_zoom(delta)

# ==================================================
# KEYBOARD MOVE (WASD)
# ==================================================
func update_keyboard_movement(delta: float) -> void:
	var input: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("cam_forward"):
		input.y += 1.0
	if Input.is_action_pressed("cam_back"):
		input.y -= 1.0
	if Input.is_action_pressed("cam_left"):
		input.x -= 1.0
	if Input.is_action_pressed("cam_right"):
		input.x += 1.0

	if input == Vector2.ZERO:
		return

	input = input.normalized()

	var yaw: float = rotation.y
	var forward: Vector3 = Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right: Vector3 = Vector3(cos(yaw), 0.0, -sin(yaw))

	var dir: Vector3 = (right * input.x + forward * input.y).normalized()
	var height_factor: float = clamp(global_position.y / 20.0, 0.6, 3.0)

	global_position += dir * move_speed * height_factor * delta
	update_global_camera_position()

# ==================================================
# KEYBOARD ROTATE (Q / E)
# ==================================================
func update_keyboard_rotation(delta: float) -> void:
	if Input.is_action_pressed("cam_rotate_l"):
		rotate_y(rotate_speed * delta)
		update_global_camera_rotation()
	elif Input.is_action_pressed("cam_rotate_r"):
		rotate_y(-rotate_speed * delta)
		update_global_camera_rotation()

# ==================================================
# ZOOM
# ==================================================
func update_zoom(delta: float) -> void:
	if zoom_velocity == 0.0:
		return

	global_position.y = clamp(
		global_position.y + zoom_velocity * delta,
		min_height,
		max_height
	)

	zoom_velocity = lerp(zoom_velocity, 0.0, 10.0 * delta)
	update_global_camera_position()

# ==================================================
# PAN – SCREEN SPACE 1:1 (NO INERTIA)
# ==================================================
func pan_screen_space(current_mouse_pos: Vector2) -> void:
	var a: Vector3 = ray_to_ground(last_mouse_pos)
	var b: Vector3 = ray_to_ground(current_mouse_pos)

	var move: Vector3 = a - b
	global_position += move

	last_mouse_pos = current_mouse_pos

# ==================================================
# RAY → GROUND (Y = 0) – ALWAYS RETURNS Vector3
# ==================================================
func ray_to_ground(screen_pos: Vector2) -> Vector3:
	var origin: Vector3 = project_ray_origin(screen_pos)
	var dir: Vector3 = project_ray_normal(screen_pos)

	var t: float = -origin.y / dir.y
	return origin + dir * t

func update_global_camera_position():
	Global.camera_position = global_position
	terrain.update_chunk()

func update_global_camera_rotation():
	Global.camera_rotation = global_rotation
