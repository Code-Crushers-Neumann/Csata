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


func _on_VirtualJoystick2_analogic_chage(move):
	get_node("Gun").rotation_degrees = move.angle()*x
	if(abs(move.angle()*x) == 0):
		get_node("Gun").rotation_degrees = last2
	last2 = move.angle()*x

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
