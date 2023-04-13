extends Node2D

var Player = preload("res://entities/player/player.tscn");

var current_room;
var rooms = [];
var offset = 100;

func _ready():
	var peer = NetworkedMultiplayerENet.new();
	
	if "--server" in OS.get_cmdline_args():
			peer.create_server(3000, 32);
	else: 
		peer.create_client('127.0.0.1', 3000);
		$Menu/Create.connect("button_down", self, "create_room");
		$Menu/Join.connect("button_down", self, "go_join_room");
		$Lobby/Start.connect("button_down", self, "start_game");
		$Join.connect("join_room", self, "on_join_room");
		
	get_tree().network_peer = peer;
	pass


func get_room(id):
	for room in rooms:
		if (room.id == id):
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

remote func create_new_room(name):
	var rng = RandomNumberGenerator.new();
	var id = get_tree().get_rpc_sender_id();	
	
	rng.randomize();
	
	var room = {
		id = rng.randi_range(0, 9999),
		players = [{
			id = id,
			name = name,
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
	$Menu.hide();
	$Join.hide();
	$Lobby.set_room(room.id);
	$Lobby.show();
	
	current_room = room;

remote func player_enter_room(data):
	current_room = data.room;
	$Lobby.set_players(data.room.players);

func start_game():
	rpc_id(1, 'start_room_game', current_room);
	
remote func start_room_game(room):	
	rpc_to_room(room.id, 'game_started', room);

remote func game_started(room):
	$Menu.hide();
	$Join.hide();
	$Lobby.hide();
	
	current_room.players[0].instance = Player.instance();
	current_room.players[1].instance = Player.instance();
	
	current_room.players[0].x = (get_viewport_rect().size / 2).x;
	current_room.players[1].x = (get_viewport_rect().size / 2).x;
	
	var current = get_current_player(current_room);
	var other = get_other_player(current_room);
	
	add_player(other.instance, false, Position.Bottom, Color(1.3, 0.7, 1));
	add_player(current.instance, true, Position.Top, Color(0.5, 1, 1.3));
	
	current.instance.connect('move', self, 'on_player_move');
	# TODO: Add players and ball
	
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

func on_player_move(x):
	rpc_id(1, 'update_player', {
		room = current_room,
		x = x,
	});
	
remote func update_player(data):
	var id = get_tree().get_rpc_sender_id();
	var player = get_player(id, data.room);
	
	player.x = data.x;
	
	rpc_to_room(data.room.id, 'update_players_position', data.room);
	
remote func update_players_position(room):
	current_room.players[0].x = room.players[0].x;
	current_room.players[1].x = room.players[1].x;
	
	for player in current_room.players:
		player.instance.position.x = player.x;
	
