extends KinematicBody2D  # Assuming the bullet is a KinematicBody2D

export var speed: float = 375.0
var direction: Vector2 = Vector2.ZERO  # Declare the direction variable
onready var player = get_tree().get_root().get_child(15).get_node("test_player")

var hangzott = false

func _physics_process(delta):
    if direction != Vector2.ZERO:
        move_and_slide(direction * speed)
        self.rotation_degrees = direction.angle() * (180/PI)
        if !hangzott:
            hangzott = true
            get_node("Boombox").play_effect(load("res://sounds/elemental-magic-spell-impact-outgoing-228342"+["1","2","3"].pick_random()+".mp3"))


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://addons/egoventure/nodes/boombox.tscn").instance())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body:Node):
	if "WillStay" in body.name:
		self.queue_free()
	if "ToOpen" in body.name:
		self.queue_free()
	if "player" in body.name:
		if player.can_take_damage:
			player.can_take_damage = false
			player.get_node("DamageCooldownTimer").start()
			player.set_health(player.health - 1)
		self.queue_free()


