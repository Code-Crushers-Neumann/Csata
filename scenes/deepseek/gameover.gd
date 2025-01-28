extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#MainMenu.connect("new_game", self, "sajt")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func sajt():
	EgoVenture.change_scene("res://scenes/deepseek/build.tscn")


func _on_Hotspot_activate():
	print("MEGNYOMVA")
	MainMenu.toggle()
	#EgoVenture.in_game_configuration.continue_state = null
	get_node("/root/MainMenu/Menu/MainMenu/Margin/VBox/MenuItems/Resume").hide()
	get_node("/root/MainMenu/Menu/MainMenu/Margin/VBox/MenuItems/NewGame").show()
