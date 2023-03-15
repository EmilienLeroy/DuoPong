extends Node2D

var Player = preload("res://entities/player/player.tscn");
var Ball = preload("res://entities/ball/ball.tscn");
var offset = 100;

func _ready():
	randomize();

	add_player(true, -1);
	add_player(false, 1);
	add_ball(Vector2.DOWN);
	
	pass


func add_player(playable, ball_direction):
	var player = Player.instance();
	
	add_child(player);
	
	player.playable = playable;
	player.ball_direction = ball_direction;
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
