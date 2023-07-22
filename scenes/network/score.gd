extends Node2D

var players = [];

func set_players(p):
	players = p;
	$Players.text = '';
	
	for player in players:
		$Players.text = $Players.text + ' \n ' + player.name + ': ' + str(player.score);
