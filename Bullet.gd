extends CharacterBody2D


const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var shooter: CharacterBody2D

func _ready():
	direction = Vector2(1,0).rotated(rotation)

func _physics_process(delta):
	velocity = SPEED * direction
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * 0.5 * delta
		
	move_and_slide()


func _on_area_2d_body_entered(body):
	if (body.is_in_group("Player")):
		body.damage(50, shooter.name.to_int())
	self.queue_free()
