extends Node2D

var rooms = [];

func _ready():
	var peer = NetworkedMultiplayerENet.new();
	
	if "--server" in OS.get_cmdline_args():
			peer.create_server(3000, 32);
	else: 
		peer.create_client('127.0.0.1', 3000);
		$Menu/Create.connect("button_down", self, "create_room");
		
	get_tree().network_peer = peer;
	pass


func get_room(id):
	for room in rooms:
		if (room.id == id):
			return room;
	
	return null;

remote func create_new_room():
	var id = get_tree().get_rpc_sender_id();	
	var room = {
		id = randi(),
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

remote func room_created(room):
	Router.goto_scene('res://scenes/network/lobby.tscn', { "room": room });


