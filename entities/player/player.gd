extends KinematicBody2D

export var playable = true;
export var goal_position = Position.Top;

func _ready():
	$Touch.connect("input_event", self, "on_input_event");
	$Particles.direction.y = goal_position;
	pass

func on_input_event(viewport, event, shape_idx):
	if !event is InputEventScreenDrag or !playable:
		return	

	position.x = event.position.x
