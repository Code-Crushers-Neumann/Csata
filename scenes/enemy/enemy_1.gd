extends KinematicBody2D

onready var player = get_tree().get_root().get_child(15).get_node("test_player")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().enemies.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(player.get_parent().player_x == get_parent().id[1] && player.get_parent().player_y == get_parent().id[0]):
		self.move_and_slide((player.global_position-global_position).normalized()*100)


