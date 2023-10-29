extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer: ENetMultiplayerPeer
var server_available = false



# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(server_connected)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		create_server()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called from server and clients
func player_connected(id):
	print("Player Connected " + str(id))

# Called from server and clients
func player_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
	
	
# Called only from clients
func server_connected():
	print("Server Connected")
	SendPlayerInformation.rpc_id(1, $HBoxContainer/VBoxContainer/MarginContainer/LineEdit.text, multiplayer.get_unique_id())

# Called only from clients
func connection_failed():
	print("Failed to Connect")
	
	
@rpc("any_peer")
func SendPlayerInformation(name, id):
	print(multiplayer.get_unique_id(), name, id)
	if !GameManager.Players.has(id):
		print(name + " has joined")
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			print("server" + GameManager.Players[i].name)
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://testScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	create_server()
	SendPlayerInformation($HBoxContainer/VBoxContainer/MarginContainer/LineEdit.text, multiplayer.get_unique_id())
	server_available = true

func create_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("Cannot host: " + str(error))
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Players!")
	

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	server_available = true
	print("Joined")


func _on_start_game_button_down():
	if !server_available:
		create_server()
		SendPlayerInformation($HBoxContainer/VBoxContainer/MarginContainer/LineEdit.text, multiplayer.get_unique_id())
	StartGame.rpc()
	pass # Replace with function body.
