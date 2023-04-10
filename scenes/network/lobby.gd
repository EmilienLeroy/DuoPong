extends Node2D

var room = 0;

func set_room(r):
	room = r;
	$Code.text = "Code: " + str(room);


