extends Node2D

var rooms = [];

func _ready():
	var peer = NetworkedMultiplayerENet.new();
	peer.create_server(3000, 32);
	get_tree().network_peer = peer;
	pass


func get_room(id):
	for room in rooms:
		if (room.id == id):
			return room;
	
	return null;

remote func create_room():
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
	

