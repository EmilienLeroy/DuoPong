extends Node2D

var room = 0;

func init(data):
	room = data.room;

func _ready():
	$Code.text = "Code: " + str(room)
	pass

