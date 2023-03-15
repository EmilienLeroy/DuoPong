extends Area2D

export var playable = true;
export var ball_direction = 1;

func _ready():
	connect("area_entered", self, "on_area_enter");
	pass

func _unhandled_input(event):
	if !event is InputEventScreenDrag or !playable:
		return	

	position.x = event.position.x

func on_area_enter(area):
	if (!area.is_in_group('ball')):
		return;
	
	if (area.direction == Vector2.UP or area.direction == Vector2.DOWN):
		area.direction = Vector2(randf() * 2 - 1, ball_direction).normalized()
	else:
		var angle_to_vertical = area.global_position.angle_to(Vector2.DOWN);
		var new_direction = Vector2(area.direction.x, ball_direction).rotated(angle_to_vertical);
			
		area.direction = new_direction.normalized();
