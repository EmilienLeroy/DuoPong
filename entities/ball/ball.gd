extends KinematicBody2D

var CollisionParticle = preload("res://entities/ball/particles/collision.tscn");
var GoalParticle = preload("res://entities/ball/particles/goal.tscn");

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
	$FollowParticles.scale_amount += 0.25;

func add_collision_particles():
	var particles = CollisionParticle.instance();
	
	add_child(particles);
	particles.initial_velocity = speed / 3;
	particles.emitting = true;
	
	return particles;

func add_goal_particles(direction):
	var particles = GoalParticle.instance();
	
	add_child(particles);
	particles.global_position = global_position;
	particles.direction.y = direction;
	particles.emitting = true;
	
	return particles;

func destroy(goal):
	add_goal_particles(goal);
	yield(get_tree().create_timer(5.0), "timeout");
	queue_free();
