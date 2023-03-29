extends StaticBody2D

var Goal = preload("res://entities/goal/goal.tscn");
var previous_goal = "goal_left";

signal goal;

func _ready():
	$GoalTop.connect("body_entered", self, "on_goal_top_entered");
	$GoalBottom.connect("body_entered", self, "on_goal_bottom_entered");
	pass

func add_goal(color):
	var goal = Goal.instance();
	
	if (previous_goal == 'goal_right'):
		goal.animation = 'goal_left';
	else:
		goal.animation = 'goal_right';
	
	goal.color = color;
	previous_goal = goal.animation;
	
	add_child(goal);
	
	return goal;

func on_goal_top_entered(body):
	return on_goal_entered(body, Position.Top);
	
func on_goal_bottom_entered(body):
	return on_goal_entered(body, Position.Bottom);

func on_goal_entered(body, goal):
	if (!body.is_in_group('ball')):
		return;
		
	add_goal(body.color);
	emit_signal('goal', body, goal);

