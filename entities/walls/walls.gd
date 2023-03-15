extends Area2D


func _ready():
	connect("area_entered", self, "on_area_enter");
	pass 


func on_area_enter(area):
	if (!area.is_in_group('ball')):
		return;
	
	var angle_to_vertical = area.global_position.angle_to(Vector2.ZERO);
	var new_direction = Vector2(-area.direction.x, area.direction.y).rotated(angle_to_vertical);
	
	area.direction = new_direction.normalized();
