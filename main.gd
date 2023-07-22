extends Node2D


func _ready():
	Engine.set_target_fps(60);
	Router.goto_scene("res://scenes/network/network.tscn");
	pass 
