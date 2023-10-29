extends Node

var Players = {}

signal score_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_game():
	score_updated.emit()

@rpc("any_peer", "call_local")
func add_score(value: int, player: int):
	for p in Players:
		if Players[p].id == player:
			Players[p].score += value
	
	score_updated.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
