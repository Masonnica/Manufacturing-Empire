extends Node

@onready var mesh = $Mesh

var chunk: Vector2i = Vector2i.ZERO

var noise_map = preload("res://scripts/noise_map.gd").new()

func expand_chunk(direction: Vector2i):
	Global.world_size += direction.abs() * 10
	Global.position_origin_chunk -= direction
	
	if direction.x < 0:
		Global.rect_chunk.x += direction.x
	else:
		Global.rect_chunk.z += direction.x
	if direction.y < 0:
		Global.rect_chunk.y += direction.y
	else:
		Global.rect_chunk.w += direction.y
	
	noise_map.create_noise_image(
		Global.world_seed,
		0.01,
		5,
		0.02,
		2.0,
		Global.world_origin,
		Global.world_size,
		"res://temps/height_map.png"
	)

func update_chunk():
	var n_chunk:Vector2i
	n_chunk.x = roundi(Global.camera_position.x/50)
	n_chunk.y = roundi(Global.camera_position.z/50)
	
	if n_chunk != chunk:
		chunk = n_chunk
		update_mesh()

func update_mesh():
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height_map := Image.load_from_file("res://temps/height_map.png")
	
	build_mesh_chunk(
		st,
		chunk,
		Vector4i(20, 20, 20, 20),
		height_map,
	)
	
	# mesh.mesh = st.commit()

func build_mesh_chunk(
	st: SurfaceTool,
	chunk: Vector2i,
	offset: Vector4i,
	height_map: Image,
):
	var rect_heigh_map_cropped = Vector4i(
		(chunk.x + Global.position_origin_chunk.x -1) * 10 - offset.x,
		(chunk.y + Global.position_origin_chunk.y -1) * 10 - offset.y,
		(chunk.x * 10) + offset.z,
		(chunk.y * 10) + offset.w,
	)
