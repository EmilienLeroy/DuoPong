extends Node2D


func _ready():
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	$Name.text = 'player ' + str(rng.randi_range(0, 9999));
