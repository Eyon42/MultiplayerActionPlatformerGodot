extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = ["Pepe", "José", "Roberto", "Alicia", "Eyon"].pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
