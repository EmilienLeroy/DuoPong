extends Node2D

var Player = preload("res://entities/player/player.tscn");
var offset = 100;

func _ready():
	add_player(true);
	add_player(false);
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
