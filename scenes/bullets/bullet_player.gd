extends KinematicBody2D

var hova = Vector2(0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://addons/egoventure/nodes/boombox.tscn").instance())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func merre(move):
	hova = move


var hangzott = false

func _physics_process(delta):
	var velocity = move_and_slide(hova*500)
	if velocity == Vector2.ZERO:
		self.queue_free()
	else:
		if !hangzott:
			hangzott = true
			get_node("Boombox").play_effect(load("res://sounds/cannon-shot-14799"+["1","2","3"].pick_random()+".mp3"))

func _on_Area2D_body_entered(body:Node):
	if "enemy" in body.name:
		body.die()
		self.queue_free()
	if "bullet" in body.name:
		body.die()
		self.queue_free()
	if "WillStay" in body.name:
		self.queue_free()
	if "ToOpen" in body.name:
		self.queue_free()
