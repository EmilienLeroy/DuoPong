extends Node2D


func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client('127.0.0.1', 3000);
	get_tree().network_peer = peer;
	get_tree().connect("network_peer_connected", self, "_player_connected");
	pass 


func _player_connected(id):
	if (id != 1):
		return;
	
	create_room();
	pass
	
func create_room():
	rpc_id(1, 'create_room');

remote func room_created(room):
	print(room)
