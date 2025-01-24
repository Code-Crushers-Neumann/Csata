extends KinematicBody2D

var velocity := Vector2()
var speed = 375
var x = (180/PI)
var last = 0
var last2 = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	print("lő")
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
	print(move.angle()*x)
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
