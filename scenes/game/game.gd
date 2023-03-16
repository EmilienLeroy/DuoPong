extends Node2D

var Player = preload("res://entities/player/player.tscn");
var Ball = preload("res://entities/ball/ball.tscn");
var offset = 100;

func _ready():
	randomize();

	add_player(true);
	add_player(false);
	add_ball(Vector2(rand_range(0.5, 5), get_random_direction()));
	pass


func add_player(playable):
	var player = Player.instance();
	
	add_child(player);
	
	player.playable = playable;
	player.global_position.x = (get_viewport_rect().size / 2).x
	
	if (playable):
		player.global_position.y = get_viewport_rect().size.y - offset;
	else:
		player.global_position.y = offset;

	return player;

func add_ball(direction):
	var ball = Ball.instance();
	
	ball.init(direction, get_viewport_rect().size / 2);
	add_child(ball);
	
	return ball;

func get_random_direction():
	if randi() % 2 == 0:
		return 1
	else:
		return -1
