extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("score_updated", _on_score_updated)


func _on_score_updated():
	var score_text = ""
	for p in GameManager.Players:
		if score_text != "":
			score_text += "\n"
		var player = GameManager.Players[p]
		score_text += player.name + " - " + str(player.score)
	text = score_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
