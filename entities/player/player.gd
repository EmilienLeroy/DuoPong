extends KinematicBody2D

export var playable = true;

func _ready():
	pass

func _unhandled_input(event):
	if !event is InputEventScreenDrag or !playable:
		return	

	position.x = event.position.x
