extends Node2D

var color = Color(1.5, 1.5, 1.5);
var animation = "goal_right";

func _ready():
	global_position = get_viewport_rect().size / 2;
	
	$Text.add_color_override("font_color", color);
	$Animation.play(animation);
	pass 

