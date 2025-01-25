extends KinematicBody2D

var velocity := Vector2()
var speed = 375
var x = (180/PI)
var last = 0
var last2 = 0

var can_take_damage = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for path in heart_paths:
		hearts.append(get_node(path))
	update_health_bar()

func _physics_process(delta):
	move_and_slide(velocity*speed)


var can_shoot = true

func _on_VirtualJoystick2_analogic_chage(move):
	get_node("Gun").rotation_degrees = move.angle() * x
	if abs(move.angle() * x) == 0:
		get_node("Gun").rotation_degrees = last2
	last2 = move.angle() * x

	if can_shoot:
		shoot_bullet(move)
		can_shoot = false
		$ShootCooldownTimer.start()

func shoot_bullet(move):
	var bullet_scene = load("res://scenes/bullets/bullet_player.tscn")
	var bullet = bullet_scene.instance()
	bullet.merre(move)
	bullet.position = get_node("Gun").global_position
	bullet.rotation_degrees = get_node("Gun").rotation_degrees
	get_parent().add_child(bullet)

func _on_ShootCooldownTimer_timeout():
	can_shoot = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_VirtualJoystick_analogic_chage(move):
	velocity = move
	#print(move.angle()*x)
	if(abs(move.angle()*x) >= 90):
		get_node("CollisionShape2D/Sprite").flip_h = true
		get_node("CollisionShape2D/Sprite").play("default",true)
	else:
		get_node("CollisionShape2D/Sprite").play("default",false)
		get_node("CollisionShape2D/Sprite").flip_h = false

	if(velocity == Vector2(0,0)):
		get_node("CollisionShape2D/Sprite").stop()
		if(abs(last) >= 90):
			get_node("CollisionShape2D/Sprite").flip_h = true
		else:
			get_node("CollisionShape2D/Sprite").flip_h = false
	last = move.angle()*x


export(Array, NodePath) var heart_paths = []

# Resolved TextureRect nodes
var hearts: Array = []

# Player's health (max 9)
var health: int = 9


# Function to update the health bar
func update_health_bar():
	var full_hearts = health / 3  # Number of full hearts
	var half_hearts = health % 3  # Remainder to determine half hearts

	for i in range(hearts.size()):
		if i < full_hearts:
			hearts[i].texture = preload("res://images/player/heart_full.png")  # Full heart
		elif i == full_hearts and half_hearts > 0:
			hearts[i].texture = preload("res://images/player/heart_half.png")  # Half heart
		else:
			hearts[i].texture = preload("res://images/player/heart_empty.png")  # Empty heart

# Function to change health (call this when the player takes damage or heals)
func set_health(new_health: int):
	health = clamp(new_health, 0, 9)  # Ensure health stays between 0 and 9
	update_health_bar()
	if health == 0:
		self.queue_free()


func _on_DamageCooldownTimer_timeout():
	can_take_damage = true
