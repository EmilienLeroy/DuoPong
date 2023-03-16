extends StaticBody2D

signal goal;

enum Goal {
	Top,
	Bottom
}

func _ready():
	$GoalTop.connect("body_entered", self, "on_goal_top_entered");
	$GoalBottom.connect("body_entered", self, "on_goal_bottom_entered");
	pass

func on_goal_top_entered(body):
	return on_goal_entered(body, Goal.Top);
	
func on_goal_bottom_entered(body):
	return on_goal_entered(body, Goal.Bottom);

func on_goal_entered(body, goal):
	if (!body.is_in_group('ball')):
		return;
		
	emit_signal('goal', body, goal);

