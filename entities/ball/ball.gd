extends Area2D


export var speed = 200;
var direction;

func init(d, p):
	direction = d;
	position = p;

func _process(delta):
	speed += delta * 2;
	position += speed * delta * direction;
