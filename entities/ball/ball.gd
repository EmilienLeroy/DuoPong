extends KinematicBody2D

export var speed = 300;
export var max_speed = 1000;
export var increase_speed = 30;
var direction = Vector2.ZERO;

func init(d, p):
	direction = d.normalized();
	position = p;

func _physics_process(delta):
	var collision_info = move_and_collide(direction * speed * delta);
	
	if (!collision_info):
		return;
	
	direction = direction.bounce(collision_info.normal);
	
	if (speed > max_speed):
		return;
		
	speed = speed + increase_speed;
