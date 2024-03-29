extends Node2D

var Player = preload("res://entities/player/player.tscn");
var Ball = preload("res://entities/ball/ball.tscn");

var current_room;
var current_ball;
var rooms = [];
var offset = 100;

func _ready():
	var url = ProjectSettings.get('global/network_url');
	var port = ProjectSettings.get('global/network_port');
	var peer = NetworkedMultiplayerENet.new();
	
	if "--server" in OS.get_cmdline_args():
			peer.create_server(port, 4095);
			get_tree().connect("network_peer_disconnected", self, "on_player_disconnected");
	else: 
		peer.create_client(url, port);
		$Menu/Create.connect("button_down", self, "create_room");
		$Menu/Join.connect("button_down", self, "go_join_room");
		$Lobby/Start.connect("button_down", self, "start_game");
		$Score/Replay.connect("button_down", self, "replay_game");
		$Score/Leave.connect("button_down", self, "leave_game");
		$Walls.connect("goal", self, "on_goal");
		$Join.connect("join_room", self, "on_join_room");
		
	get_tree().network_peer = peer;
	pass


func get_room(id):
	for room in rooms:
		if (room.id == id):
			return room;
	
	return null;
	
func get_room_with_player(id):
	for room in rooms:
		for player in room.players:
			if (player.id == id):
				return room;
	
	return null;

func get_player(id, room):
	for player in room.players:
		if (player.id == id):
			return player;
			
	return null;

func get_current_player(room):
	var id = get_tree().get_network_unique_id()
	
	return get_player(id, room);
	
func get_other_player(room):
	var id = get_tree().get_network_unique_id()
	
	for player in room.players:
		if (player.id != id):
			return player;
			
	return null;

func on_player_disconnected(id):
	var room = get_room_with_player(id);
	
	if (!room):
		return;
	
	room.players.erase(get_player(id, room));

	rpc_to_room(room.id, 'player_leave_room', {
		room = room
	});
	

remote func create_new_room(name):
	var rng = RandomNumberGenerator.new();
	var id = get_tree().get_rpc_sender_id();	
	
	rng.randomize();
	
	var room = {
		id = rng.randi_range(0, 9999),
		config = {
			score = 5,	
		},
		players = [{
			id = id,
			name = name,
			ball = Vector2.ZERO,
			score = 0,
			x = 0,
		}],
	}
	
	rooms.append(room);
	rpc_to_room(room.id, 'room_created', room);
	
func rpc_to_room(id, name, data):
	var room = get_room(id);
	
	if (!room or !room.players):
		return;
		
	for player in room.players:
		rpc_id(player.id, name, data);
	
func create_room():
	rpc_id(1, 'create_new_room', $Menu/Name.text);

func on_join_room(room):
	var data = {
		room = room,
		name = $Menu/Name.text,
	}
	
	rpc_id(1, 'join_room', data);

remote func join_room(data):
	var id = get_tree().get_rpc_sender_id();
	var room = get_room(int(data.room));
	var player = {
		id = id,
		name = data.name,
		ball = Vector2.ZERO,
		score = 0,
		x = 0,
	};
	
	if (!room):
		return;
	
	room.players.append(player);
	
	rpc_id(id, 'go_room', room);
	rpc_to_room(room.id, 'player_enter_room', {
		room = room,
		player = player
	});

func go_join_room():
	$Menu.hide();
	$Join.show();

remote func room_created(room):
	$Menu.hide();
	$Lobby.set_room(room.id);
	$Lobby.set_players(room.players);
	$Lobby.show();
	
	current_room = room;

remote func go_room(room):
	$Score.hide();
	$Menu.hide();
	$Join.hide();
	$Lobby.set_room(room.id);
	$Lobby.show();
	
	current_room = room;

remote func player_enter_room(data):
	current_room = data.room;
	$Lobby.set_players(data.room.players);
	
remote func player_leave_room(data):
	$Lobby.set_players(data.room.players);
	$Score.set_players(data.room.players);
	
	for player in current_room.players:
		if (player.instance):
			player.instance.queue_free();
	
	if (current_ball):
		current_ball.queue_free();
		$Score.show();
		
	$ScoreTop.hide();
	$ScoreBottom.hide();

func start_game():
	rpc_id(1, 'start_room_game', current_room);
	
remote func start_room_game(room):	
	room = update_ball(room);
	
	rpc_to_room(room.id, 'game_started', room);
	
func replay_game():
	for player in current_room.players:
		player.score = 0;

	go_room(current_room);
	
func leave_game():
	get_tree().network_peer = null;
	Router.goto_scene('res://scenes/network/network.tscn');

remote func game_started(room):
	$Menu.hide();
	$Join.hide();
	$Lobby.hide();
	
	$ScoreBottom.update_score(0);
	$ScoreTop.update_score(0);
	
	$ScoreTop.show();
	$ScoreBottom.show();
	
	current_room = room;
	
	current_room.players[0].instance = Player.instance();
	current_room.players[1].instance = Player.instance();
	
	current_room.players[0].x = (get_viewport_rect().size / 2).x;
	current_room.players[1].x = (get_viewport_rect().size / 2).x;
	
	var current = get_current_player(current_room);
	var other = get_other_player(current_room);
	
	add_player(other.instance, false, Position.Bottom, Color(1.3, 0.7, 1));
	add_player(current.instance, true, Position.Top, Color(0.5, 1, 1.3));
	
	current_ball = add_ball(current.ball, current_room.players[0].id == current.id);
	current.instance.connect('move', self, 'on_player_move');
	
func add_player(player, playable, goal, color):	
	player.goal_position = goal;
	player.color = color;
	
	add_child(player);
	
	player.playable = playable;
	player.global_position.x = (get_viewport_rect().size / 2).x
	
	if (goal == Position.Top):
		player.global_position.y = get_viewport_rect().size.y - offset;
	else:
		player.global_position.y = offset;

	return player;
	
remote func spawn_ball(room):	
	var current = get_current_player(room);
	
	current_ball = add_ball(current.ball, room.players[0].id == current.id);
	
func update_ball(room):
	var direction = get_random_direction();
	var invert_direction = Vector2(-direction.x, -direction.y);
	
	room.players[0].ball = direction;
	room.players[1].ball = invert_direction;
	
	return room;

func add_ball(direction, sync_ball):
	var ball = Ball.instance();
	
	ball.init(direction, get_viewport_rect().size / 2);
	call_deferred("add_child", ball);
	
	if (sync_ball):
		ball.connect("new_direction", self, "on_ball_collision");
	
	return ball;

func get_random_direction():
	var x = rand_range(-1, 1);
	
	if randi() % 2 == 0:
		return Vector2(x, 1);
	else:
		return Vector2(x, -1);

func on_ball_collision(direction):
	var other = get_other_player(current_room);
	
	rpc_id(other.id, 'sync_ball', direction);

func on_player_move(x):
	rpc_id(1, 'update_player', {
		room = current_room,
		x = x,
	});

func on_goal(ball, goal):
	ball.destroy(goal);
	
	if (goal != Position.Top):
		return;
	
	rpc_id(1, 'increase_score', {
		room = current_room,
		goal = goal
	});

remote func update_player(data):
	var id = get_tree().get_rpc_sender_id();
	var player = get_player(id, data.room);
	
	player.x = data.x;
	
	rpc_to_room(data.room.id, 'update_players_position', data.room);

remote func increase_score(data):
	var id = get_tree().get_rpc_sender_id();
	var player = get_player(id, data.room);
	
	player.score = player.score + 1;
	
	if (player.score == data.room.config.score): 
		rpc_to_room(data.room.id, 'game_over', data.room)
		return;
	
	update_ball(data.room);
	rpc_to_room(data.room.id, 'spawn_ball', data.room);
	rpc_to_room(data.room.id, 'update_score', data.room);
	
remote func update_players_position(room):
	var current = get_current_player(current_room);
	var other = get_other_player(current_room);
	
	current_room.players[0].x = room.players[0].x;
	current_room.players[1].x = room.players[1].x;
	
	if (current.instance):
		current.instance.position.x = current.x;
	
	if (other.instance): 
		other.instance.position.x = get_viewport_rect().size.x - other.x;
	
remote func sync_ball(data):
	var direction = data.direction;
	var ball_position = data.position;
	
	var invert_direction = Vector2(-direction.x, -direction.y);
	
	current_ball.position.x = get_viewport_rect().size.x - ball_position.x;
	current_ball.position.y = get_viewport_rect().size.y - ball_position.y;
	current_ball.direction = invert_direction;
	current_ball.speed = data.speed;

remote func update_score(room):
	var current = get_current_player(current_room);
	var other = get_other_player(current_room);
	
	current_room.players[0].score = room.players[0].score;
	current_room.players[1].score = room.players[1].score;
	
	$ScoreBottom.update_score(current.score);
	$ScoreTop.update_score(other.score);

remote func game_over(room):
	for player in current_room.players:
		player.instance.queue_free();
	
	$Score.set_players(room.players);
	$ScoreBottom.hide();
	$ScoreTop.hide();
	$Score.show();
