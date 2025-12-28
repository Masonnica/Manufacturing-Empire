extends Node

var noise_map = preload("res://scripts/noise_map.gd").new()

func new_game():
	if Global.world_seed == 0:
		var _seed = 0
		for i in range(1, 6):
			_seed += randi() * i
			_seed += _seed * i
		Global.world_seed = _seed
	
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
