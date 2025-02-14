extends Node2D

# Define the possible directions
var directions = ["Up", "Down", "Left", "Right"]

# Define the opposite directions
var opposite = {"Up": "Down", "Down": "Up", "Left": "Right", "Right": "Left"}

# Grid dimensions (can be changed)
var grid_width = 2  # Example: 3 columns
var grid_height = 2 # Example: 3 rows

# Player position in the grid
var player_x: int
var player_y: int

# Difficulty
var enemy_types = ["1","1"]
var min_enemy = 1

# Room dimensions in pixels
var room_width = 1920
var room_height = 1080

# Initialize the grid dynamically
var grid = []
var enemy_grid = []  # Grid to determine if a room has enemies

# Reference to the Camera2D node
onready var camera = $Camera2D

# Track all instanced rooms
var instanced_rooms = []

# Minimap colors
enum MinimapColor { GREY, GREEN, RED, BLUE }

# Reference to the GridContainer and ColorRect nodes
onready var minimap_grid = $CanvasLayer/MinimapUI/GridContainer
onready var full_map_grid = $CanvasLayer/FullMapUI/GridContainer
var full_map_visible = false

# Function to generate a room based on constraints
func generate_room(x: int, y: int) -> Array:
	var possible_directions = directions.duplicate()
	
	# Apply edge constraints
	if x == 0:
		possible_directions.erase("Left")  # Leftmost column can't have "Left"
	if x == grid_width - 1:
		possible_directions.erase("Right") # Rightmost column can't have "Right"
	if y == 0:
		possible_directions.erase("Up")    # Top row can't have "Up"
	if y == grid_height - 1:
		possible_directions.erase("Down")  # Bottom row can't have "Down"
	
	# Ensure at least one direction is chosen
	var room_directions = []
	var num_directions = randi() % possible_directions.size() + 1
	for i in range(num_directions):
		var dir = possible_directions[randi() % possible_directions.size()]
		if not room_directions.has(dir):
			room_directions.append(dir)
	
	return room_directions

# Fill the grid with rooms
func fill_grid():
	grid = []  # Reset the grid
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(generate_room(x, y))
		grid.append(row)

# Ensure door matching between adjacent rooms
func match_doors():
	for y in range(grid_height):
		for x in range(grid_width):
			# Check right neighbor
			if x < grid_width - 1:
				if grid[y][x].has("Right"):
					if not grid[y][x + 1].has("Left"):
						grid[y][x + 1].append("Left")
				else:
					if grid[y][x + 1].has("Left"):
						grid[y][x].append("Right")
			# Check bottom neighbor
			if y < grid_height - 1:
				if grid[y][x].has("Down"):
					if not grid[y + 1][x].has("Up"):
						grid[y + 1][x].append("Up")
				else:
					if grid[y + 1][x].has("Up"):
						grid[y][x].append("Down")

# Check if the dungeon is fully connected using flood fill
func is_fully_connected() -> bool:
	var visited = []  # Track visited rooms
	for y in range(grid_height):
		visited.append([])
		for x in range(grid_width):
			visited[y].append(false)
	
	# Start flood fill from the first room (0, 0)
	var queue = [[0, 0]]
	visited[0][0] = true
	var reachable_rooms = 1
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var x = current[0]
		var y = current[1]
		
		# Check all possible directions
		if grid[y][x].has("Up") and y > 0 and not visited[y - 1][x]:
			visited[y - 1][x] = true
			queue.append([x, y - 1])
			reachable_rooms += 1
		if grid[y][x].has("Down") and y < grid_height - 1 and not visited[y + 1][x]:
			visited[y + 1][x] = true
			queue.append([x, y + 1])
			reachable_rooms += 1
		if grid[y][x].has("Left") and x > 0 and not visited[y][x - 1]:
			visited[y][x - 1] = true
			queue.append([x - 1, y])
			reachable_rooms += 1
		if grid[y][x].has("Right") and x < grid_width - 1 and not visited[y][x + 1]:
			visited[y][x + 1] = true
			queue.append([x + 1, y])
			reachable_rooms += 1
	
	# If all rooms are reachable, the dungeon is fully connected
	return reachable_rooms == grid_width * grid_height

# Generate the enemy grid with one room marked as False (player spawn)
func generate_enemy_grid():
	enemy_grid = []  # Reset the enemy grid
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(true)  # Default to True (enemies present)
		enemy_grid.append(row)
	
	# Randomly select one room to be False (no enemies, player spawn)
	var spawn_x = randi() % grid_width
	var spawn_y = randi() % grid_height
	enemy_grid[spawn_y][spawn_x] = false
	player_x = spawn_x
	player_y = spawn_y

# Print the resulting grid
func print_grid():
	print("Room Directions Grid:")
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(grid[y][x])
		print(row)
	
	print("\nEnemy Grid (False = Player Spawn):")
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(enemy_grid[y][x])
		print(row)

# Build the dungeon by instantiating room scenes
func build_dungeon():
	# Clear previously instanced rooms
	clear_rooms()
	
	for y in range(grid_height):
		for x in range(grid_width):
			# Sort the room directions alphabetically
			var room_directions = grid[y][x]
			room_directions.sort()
			
			# Convert directions to scene name (e.g., "Down_Up")
			var scene_name = "_".join(room_directions)
			
			# Load the corresponding scene
			var scene_path = "res://scenes/rooms/" + scene_name + ".tscn"
			if ResourceLoader.exists(scene_path):
				var room_scene = load(scene_path)
				var room_instance = room_scene.instance()  # Use instance() in Godot 3.x
				room_instance.initiate(scene_name, [y, x], enemy_grid[y][x], enemy_types, min_enemy)
				
				# Position the room in the world
				room_instance.position = Vector2(x * room_width, y * room_height)
				
				# Set player position if this is the spawn room
				if !enemy_grid[y][x]:
					get_node("test_player").position = Vector2((x * room_width) + room_width / 2, (y * room_height) + room_height / 2)
					move_player(x, y)
				
				# Add the room to the scene and track it
				add_child(room_instance)
				instanced_rooms.append(room_instance)
			else:
				print("Scene not found: ", scene_path)
	
	# Set the camera to the player's starting position
	update_camera_position()

# Clear all previously instanced rooms
func clear_rooms():
	for room in instanced_rooms:
		room.queue_free()  # Remove the room from the scene tree
	instanced_rooms = []  # Reset the list of instanced rooms

# Update the camera position based on the player's current room
func update_camera_position():
	var camera_x = player_x * room_width + room_width / 2
	var camera_y = player_y * room_height + room_height / 2
	camera.position = Vector2(camera_x, camera_y)

# Move the player to a new room
func move_player(new_x: int, new_y: int):
	if new_x >= 0 and new_x < grid_width and new_y >= 0 and new_y < grid_height:
		player_x = new_x
		player_y = new_y
		update_camera_position()
		update_minimap()  # Update the minimap when the player moves
	else:
		print("Invalid move: Player cannot move outside the grid.")

# Generate the minimap as a 3x3 grid
func generate_minimap() -> Array:
	var minimap = []
	for i in range(3):
		var row = []
		for j in range(3):
			row.append(MinimapColor.GREY)  # Default to grey (non-existent)
		minimap.append(row)
	
	# Center the minimap around the player
	for i in range(-1, 2):
		for j in range(-1, 2):
			var x = player_x + j
			var y = player_y + i
			
			# Check if the room exists
			if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
				if x == player_x and y == player_y:
					minimap[i + 1][j + 1] = MinimapColor.BLUE  # Player's room
				elif enemy_grid[y][x]:
					minimap[i + 1][j + 1] = MinimapColor.RED  # Room with enemies
				else:
					minimap[i + 1][j + 1] = MinimapColor.GREEN  # Room without enemies
	
	return minimap

# Update the minimap display
func update_minimap():
	var minimap = generate_minimap()
	
	# Update the ColorRect nodes based on the minimap
	for i in range(3):
		for j in range(3):
			var cell_index = i * 3 + j
			var cell = minimap_grid.get_child(cell_index)
			
			match minimap[i][j]:
				MinimapColor.GREY:
					cell.color = Color(0.5, 0.5, 0.5)  # Grey
				MinimapColor.GREEN:
					cell.color = Color(0, 1, 0)  # Green
				MinimapColor.RED:
					cell.color = Color(1, 0, 0)  # Red
				MinimapColor.BLUE:
					cell.color = Color(0, 0, 1)  # Blue

# Generate the full map
func generate_full_map():
	# Clear existing ColorRect nodes
	for child in full_map_grid.get_children():
		child.queue_free()
	
	# Set the GridContainer to fill the screen
	full_map_grid.rect_min_size = Vector2(1920, 1080)
	full_map_grid.anchor_right = 1.0
	full_map_grid.anchor_bottom = 1.0
	full_map_grid.margin_right = 0
	full_map_grid.margin_bottom = 0
	
	# Calculate the size of each ColorRect
	var cell_width = 1920 / grid_width -4 
	var cell_height = 1080 / grid_height -4
	
	# Set the columns and rows for the GridContainer
	full_map_grid.columns = grid_width
	
	# Create ColorRect nodes for each room
	for y in range(grid_height):
		for x in range(grid_width):
			var color_rect = ColorRect.new()
			color_rect.rect_min_size = Vector2(cell_width, cell_height)
			full_map_grid.add_child(color_rect)
	
	# Update the full map colors
	update_full_map()

# Update the full map display
func update_full_map():
	for y in range(grid_height):
		for x in range(grid_width):
			var cell_index = y * grid_width + x
			var cell = full_map_grid.get_child(cell_index)
			
			if x == player_x and y == player_y:
				cell.color = Color(0, 0, 1)  # Blue (player's room)
			elif enemy_grid[y][x]:
				cell.color = Color(1, 0, 0)  # Red (room with enemies)
			else:
				cell.color = Color(0, 1, 0)  # Green (room without enemies)

# Toggle the full map visibility
func toggle_full_map():
	full_map_visible = !full_map_visible
	$CanvasLayer/FullMapUI.visible = full_map_visible
	
	if full_map_visible:
		update_full_map()

# Handle input for toggling the full map
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			# Check if the click is on the minimap
			var minimap_rect = minimap_grid.get_global_rect()
			#print("Minimap Rect: ", minimap_rect)
			#print("Click Position: ", event.position)
			
			if minimap_rect.has_point(event.position):
				#print("Clicked on minimap")
				toggle_full_map()
			
			# Check if the click is anywhere on the screen while the full map is visible
			elif full_map_visible:
				#print("Clicked on full map (anywhere on screen)")
				toggle_full_map()
	
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE and full_map_visible:
			#print("ESC key pressed")
			toggle_full_map()

# Main function to generate and build the dungeon
func generate_dungeon():
	randomize()  # Ensure randomness
	var fully_connected = false
	
	while not fully_connected:
		fill_grid()
		match_doors()
		fully_connected = is_fully_connected()
	
	generate_enemy_grid()  # Generate the enemy grid
	build_dungeon()
	generate_full_map()  # Generate the full map
	update_minimap()  # Initialize the minimap

func sajt():
	EgoVenture.change_scene("res://scenes/deepseek/build.tscn")
# Call the main function when the script runs
func _ready():
	Inventory.disable()
	get_node("/root/MainMenu/Menu/MainMenu/Margin/VBox/MenuItems/NewGame").hide()
	EgoVenture.game_started = true
	Boombox.play_music(load("res://music/eerie-echoes-of-the-abyss-252094.mp3"))
	#EgoVenture.save_continue()
	MainMenu.saveable = false
	generate_dungeon()
	yield(get_tree().create_timer(1), "timeout")
	get_node("Camera2D").smoothing_enabled = true
	print("Full Map Grid Size: ", full_map_grid.rect_size)
	print("Full Map Grid Position: ", full_map_grid.rect_position)
	for i in range(full_map_grid.get_child_count()):
		var cell = full_map_grid.get_child(i)
		print("Cell ", i, " Size: ", cell.rect_size, " Position: ", cell.rect_position)

# Function to reset the dungeon
func reset_dungeon():
	generate_dungeon()
	get_node("CanvasLayer/ColorRect").visible = true
	Boombox.play_effect(load("res://sounds/level-up-289723.mp3"))
	yield(get_tree().create_timer(1),"timeout")
	get_node("CanvasLayer/ColorRect").visible = false


func _on_Hotspot_activate():
	MainMenu.toggle()

var gameover = false
func _process(delta):
	if !Boombox.is_music_playing() && Boombox.get_music() != load("res://music/a-black-dawn-music-box-167993.mp3"):
		gameover = true
		yield(Boombox,"effect_finished")
		if gameover && Boombox.get_music() != load("res://music/a-black-dawn-music-box-167993.mp3"):
			gameover = false
			Boombox.play_music(load("res://music/a-black-dawn-music-box-167993.mp3"))
			EgoVenture.change_scene("res://scenes/deepseek/gameover.tscn")