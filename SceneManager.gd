extends Node2D

@export var PlayerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		add_child(currentPlayer)
		var spawn_locations = get_tree().get_nodes_in_group("PlayerSpawnPoint")
		for spawn in spawn_locations:
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1
	GameManager.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
