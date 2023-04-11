extends Node2D

var room = 0;
var players = [];

func set_room(r):
	room = r;
	$Code.text = "Code: " + str(room);


func set_players(p):
	players = p;
	$Players.text = '';
	for player in players:
		$Players.text = $Players.text + ' \n ' + player.name;
	
