extends Node2D


func _ready():
	var peer = NetworkedMultiplayerENet.new();
	peer.create_server(3000, 32);
	get_tree().network_peer = peer;
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	pass

func _player_connected(id):
	print(id)
