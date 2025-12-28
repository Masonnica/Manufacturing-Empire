extends Node

# ===============================
# GAME
# ===============================
var world_seed: int = 0
var world_path: String = ""
var world_size: Vector2i = Vector2i(210, 210)
var world_origin: Vector2i = Vector2i(105, 105)
var rect_chunk: Vector4i = Vector4i(-10, -10, 10, 10) # (x1, y1, x2, y2)

# ===============================
# CAMERA
# ===============================
var camera_position: Vector3 = Vector3.ZERO
var camera_rotation: Vector3 = Vector3.ZERO

# ===============================
# TERRAIN
# ===============================
var terrian_data: Dictionary = {}
