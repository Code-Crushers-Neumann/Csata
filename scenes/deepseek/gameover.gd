extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#MainMenu.connect("new_game", self, "sajt")
	(EgoVenture.state as GameState).max_pont = load_high_score()
	if(EgoVenture.state as GameState).current_pont > (EgoVenture.state as GameState).max_pont:
		(EgoVenture.state as GameState).max_pont = (EgoVenture.state as GameState).current_pont
		save_high_score((EgoVenture.state as GameState).max_pont)
	get_node("CanvasLayer/Label").text = String((EgoVenture.state as GameState).current_pont)
	get_node("CanvasLayer/Label2").text = String((EgoVenture.state as GameState).max_pont)
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



# Function to load the high score
func load_high_score() -> int:
	if ResourceLoader.exists("user://high_score.tres"):
		var high_score_data = ResourceLoader.load("user://high_score.tres") as HighScoreResource
		return high_score_data.high_score
	else:
		# Return 0 if no high score file exists
		return 0

# Function to save the high score
func save_high_score(new_score: int):
	var high_score_data: HighScoreResource

	# Check if the resource file already exists
	if ResourceLoader.exists("user://high_score.tres"):
		high_score_data = ResourceLoader.load("user://high_score.tres") as HighScoreResource
	else:
		# Create a new resource if it doesn't exist
		high_score_data = HighScoreResource.new()

	# Update the high score if the new score is higher
	if new_score > high_score_data.high_score:
		high_score_data.high_score = new_score
		ResourceSaver.save("user://high_score.tres", high_score_data)
		print("New high score saved:", new_score)
	else:
		print("No new high score. Current high score:", high_score_data.high_score)
