extends KinematicBody2D

var hova = Vector2(0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func merre(move):
	hova = move

func _physics_process(delta):
	var velocity = move_and_slide(hova*500)
	if velocity == Vector2.ZERO:
		self.queue_free()

func _on_Area2D_body_entered(body:Node):
	if "enemy_1" in body.name:
		body.die()
		self.queue_free()
	if "WillStay" in body.name:
		self.queue_free()
	if "ToOpen" in body.name:
		self.queue_free()