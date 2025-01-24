extends Node2D

onready var player = get_tree().get_root().get_child(15).get_node("test_player")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_node("KinematicBody2D").move_and_slide((player.global_position-global_position).normalized()*175)
