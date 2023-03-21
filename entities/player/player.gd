extends KinematicBody2D

export var playable = true;

func _ready():
	$Touch.connect("input_event", self, "on_input_event")
	pass

func on_input_event(viewport, event, shape_idx):
	if !event is InputEventScreenDrag or !playable:
		return	

	position.x = event.position.x
