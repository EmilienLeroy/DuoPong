extends Node2D

var rooms = [];

func _ready():
	var peer = NetworkedMultiplayerENet.new();
	
	if "--server" in OS.get_cmdline_args():
			peer.create_server(3000, 32);
	else: 
		peer.create_client('127.0.0.1', 3000);
		$Menu/Create.connect("button_down", self, "create_room");
		$Menu/Join.connect("button_down", self, "go_join_room");
		$Join.connect("join_room", self, "on_join_room");
		
	get_tree().network_peer = peer;
	pass


func get_room(id):
	for room in rooms:
		if (room.id == id):
			return room;
	
	return null;
	
remote func create_new_room():
	var rng = RandomNumberGenerator.new();
	
	var id = get_tree().get_rpc_sender_id();	
	var room = {
		id = rng.randi_range(0, 9999),
		players = [
			id,
		],
	}
	
	rooms.append(room);
	rpc_to_room(room.id, 'room_created', room.id);
	
func rpc_to_room(id, name, data):
	var room = get_room(id);
	
	if (!room or !room.players):
		return;
		
	for player in room.players:
		rpc_id(player, name, data);
	
func create_room():
	rpc_id(1, 'create_new_room');

func on_join_room(room):
	rpc_id(1, 'join_room', room);


remote func join_room(room_id):
	var id = get_tree().get_rpc_sender_id();
	var room = get_room(int(room_id));
	
	if (!room):
		return;
	
	room.players.append(id);
	rpc_id(id, 'go_room', room);

func go_join_room():
	$Menu.hide();
	$Join.show();

remote func room_created(room):
	$Menu.hide();
	$Lobby.set_room(room);
	$Lobby.show();

remote func go_room(room):
	$Menu.hide();
	$Join.hide();
	$Lobby.set_room(room.id);
	$Lobby.show();
