extends Node2D

export var color = Color(1.3, 1.3, 1.3);
var score = 0;

func _ready():
	$Label.add_color_override("font_color", color);

func update_score(s):
	if (score == s):
		return;
	
	score = s;
	$Animation.play("update");
	$Label.text = str(score);

