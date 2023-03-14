extends KinematicBody2D


func _ready():
	pass

func _unhandled_input(event):
	if !event is InputEventScreenDrag:
		return	
	position.x = event.position.x

