extends KinematicBody2D

signal move;

export var playable = true;
export var goal_position = Position.Top;
export var color = Color(1.2, 1.2, 1.2);

func _ready():
	$HitBox.connect("body_entered", self, "on_body_entered");
	$Touch.connect("input_event", self, "on_input_event");
	$Particles.direction.y = goal_position;
	update_color(color);

func update_color(c):
	color = c;
	$Sprite.material = $Sprite.material.duplicate();
	$Sprite.material.set_shader_param("color", color);
	$Particles.color = color;

func on_input_event(viewport, event, shape_idx):
	if !event is InputEventScreenDrag or !playable:
		return	

	position.x = event.position.x;
	emit_signal("move", position.x);

func on_body_entered(body):
	if (!body.is_in_group('ball')):
		return;
		
	body.update_color(color);
