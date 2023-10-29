extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var health = 100
var authority
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $AnimatedSprite2D
@export var bullet: PackedScene

func damage(points: int, source: int):
	health -= points
	if health <= 0:
		print(health)
		if isActivePlayer():
			GameManager.add_score.rpc(1, source)
		die("bullet")
		

		
func die(cause: String):
	if cause == "fall" && isActivePlayer():
		GameManager.add_score.rpc(-1, name.to_int())
	
	var spawn= get_tree().get_nodes_in_group("PlayerReSpawnPoint")[0]
	global_position = spawn.global_position
	health = 100
	

	

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

@rpc("any_peer", "call_local")
func fire_bullet():
	var b = bullet.instantiate()
	# Does this work as a closure? Or does it just take the local data?
	# For network cost, i'm assuming local data
	b.global_position = $GunRotation/BulletSpawn.global_position
	b.rotation_degrees = $GunRotation.rotation_degrees
	b.shooter = self
	get_tree().root.add_child(b)

func isActivePlayer():
	return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _physics_process(delta):
	
	if isActivePlayer():
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			
		if position.y > 2000:
			die("fall")
			return
			
		if Input.is_action_just_pressed("Fire"):
			fire_bullet.rpc()

		var mouse_pos = get_viewport().get_mouse_position()
		var aim = Vector2(mouse_pos.x, min(position.y, mouse_pos.y))
		$GunRotation.look_at(aim)
		# Handle Jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("Walk Left", "Walk Right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# Gun facing
		var gun = $GunRotation/Famas
		var gun_rotation = fmod($GunRotation.rotation_degrees - 90, 360)
		var gunFacingLeft: bool
		if gun_rotation <= 0:
			gunFacingLeft = gun_rotation < -180
		else:
			gunFacingLeft = gun_rotation < 180
		if gunFacingLeft:
			gun.flip_v = true
		else:
			gun.flip_v = false
		
		# Flipping
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = false

		# Idle and Run
		if (velocity.x != 0):
			animation_player.play("Run")
		else:
			animation_player.play("default")
		


		move_and_slide()
