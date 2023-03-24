extends Camera2D

export var is_shake = false;
export var shake_amount = 5;

func _process(delta):
	if (!is_shake):
		return;

	set_offset(Vector2(
		rand_range(-1, 1) * shake_amount,
		rand_range(-1, 1) * shake_amount
	));

func shake():
	is_shake = true;
	
	yield(get_tree().create_timer(0.3), "timeout");
	
	is_shake = false;
	set_offset(Vector2(0, 0));
