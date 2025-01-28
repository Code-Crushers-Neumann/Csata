extends Control

func _ready():
	Inventory.disable()
	MainMenu.disabled = true

func to_menu():
	MainMenu.disabled = false
	EgoVenture.change_scene("res://scenes/menu.tscn")
