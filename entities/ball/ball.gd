extends KinematicBody2D

var CollisionParticle = preload("res://entities/ball/particles/collision.tscn");

export var speed = 350;
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
	add_collision_particles();
	
	if (speed > max_speed):
		return;
		
	speed = speed + increase_speed;

func add_collision_particles():
	var particles = CollisionParticle.instance();
	
	add_child(particles);
	particles.initial_velocity = speed / 3;
	particles.emitting = true;
	
	return particles;
	
func destroy():
	yield(get_tree().create_timer(5.0), "timeout");
	queue_free();
