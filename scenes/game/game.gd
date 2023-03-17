extends Node2D

var Player = preload("res://entities/player/player.tscn");
var Ball = preload("res://entities/ball/ball.tscn");
var offset = 100;
var scores = [0, 0];

func _ready():
	randomize();

	add_player(true);
	add_player(false);
	add_ball(get_random_direction());
	
	$Walls.connect("goal", self, "on_goal");
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
	call_deferred("add_child", ball);
	
	return ball;

func get_random_direction():
	var x = rand_range(0.5, 5);
	
	if randi() % 2 == 0:
		return Vector2(x, 1);
	else:
		return Vector2(x, -1);
		

func increase_score(scores, goal):
	scores[goal] = scores[goal] + 1; 

func update_scores(scores):
	$Canvas/ScoreBottom.text = str(scores[0]);
	$Canvas/ScoreTop.text = str(scores[1]);

func on_goal(ball, goal):
	ball.queue_free();
	add_ball(get_random_direction());
	increase_score(scores, goal);
	update_scores(scores);
