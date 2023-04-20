extends KinematicBody2D

signal new_direction;

var CollisionParticle = preload("res://entities/ball/particles/collision.tscn");
var GoalParticle = preload("res://entities/ball/particles/goal.tscn");

export var speed = 350;
export var max_speed = 1000;
export var increase_speed = 30;
export var color = Color(1.3, 1.3, 1.3);
var direction = Vector2.ZERO;

func init(d, p):
	direction = d.normalized();
	position = p;
	
func _ready():
	$Animation.play("spawn");

func _physics_process(delta):
	var collision_info = move_and_collide(direction * speed * delta);
	
	if (!collision_info):
		return;
	
	direction = direction.bounce(collision_info.normal);
	emit_signal("new_direction", { direction = direction, position = position });
	add_collision_particles();
	
	if (speed > max_speed):
		return;
		
	speed = speed + increase_speed;
	$FollowParticles.scale_amount += 0.25;

func add_collision_particles():
	var particles = CollisionParticle.instance();
	
	particles.color = color;
	add_child(particles);
	particles.initial_velocity = speed / 3;
	particles.emitting = true;
	
	return particles;

func add_goal_particles(direction):
	var particles = GoalParticle.instance();
	
	particles.color = color;
	add_child(particles);
	particles.global_position = global_position;
	particles.direction.y = direction;
	particles.emitting = true;
	
	return particles;

func update_color(c):
	color = c;
	$Texture.modulate = color;
	$FollowParticles.color = color;

func destroy(goal):
	yield(get_tree().create_timer(0.05), "timeout");
	
	add_goal_particles(goal);
	GlobalCamera.shake();
	
	yield(get_tree().create_timer(5.0), "timeout");
	queue_free();
