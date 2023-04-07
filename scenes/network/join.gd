extends Node2D

signal join_room;

func _ready():
	$Send.connect("button_down", self, "on_join_room");
	pass 


func on_join_room():
	emit_signal("join_room", $Input.text);
