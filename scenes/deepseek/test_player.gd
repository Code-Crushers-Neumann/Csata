extends KinematicBody2D

var velocity := Vector2()
var speed = 250
var x = (180/PI)
var last = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	move_and_slide(velocity*speed)


func _on_VirtualJoystick2_analogic_chage(move):
	self.rotation_degrees = move.angle()*x
	
	if(abs(move.angle()*x-last) > 90 && !(abs(move.angle()*x-last) > 180)):
		get_node("CollisionShape2D/Sprite").flip_h = false
		get_node("CollisionShape2D/Sprite").flip_v = false
	else:
		get_node("CollisionShape2D/Sprite").flip_h = true
		if(move.angle()*x >= 90-90 && 180-90 >= move.angle()*x || move.angle()*x >= -180+90 && -90+90 >= move.angle()*x):
			get_node("CollisionShape2D/Sprite").flip_v = false
		elif!(move.angle()*x >= 90-90 && 180-90 >= move.angle()*x || move.angle()*x >= -180+90 && -90+90 >= move.angle()*x):
			get_node("CollisionShape2D/Sprite").flip_v = true
	last = move.angle()*x

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VirtualJoystick_analogic_chage(move):
	velocity = move
