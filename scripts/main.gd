extends Node3D

func _ready() -> void:
	if Global.world_path == "":
		var new_game = preload("res://scripts/new_game.gd").new()
		new_game.new_game()
	else:
		pass
