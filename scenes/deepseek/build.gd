extends Node2D

# Define the possible directions
var directions = ["Up", "Down", "Left", "Right"]

# Define the opposite directions
var opposite = {"Up": "Down", "Down": "Up", "Left": "Right", "Right": "Left"}

# Grid dimensions (can be changed)
var grid_width = 2  # Example: 2 columns
var grid_height = 2 # Example: 2 rows

# Player position in the grid
var player_x: int
var player_y: int

# Room dimensions in pixels
var room_width = 1920
var room_height = 1080

# Initialize the grid dynamically
var grid = []
var enemy_grid = []  # Grid to determine if a room has enemies

# Reference to the Camera2D node
onready var camera = $Camera2D

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
				room_instance.initiate(scene_name,[y,x])
				# Position the room in the world
				room_instance.position = Vector2(x * room_width, y * room_height)
				if(!enemy_grid[y][x]):
					get_node("test_player").position = Vector2((x * room_width)+1920/2, (y * room_height)+1080/2)
				
				# Add the room to the scene
				add_child(room_instance)
				
				# Set whether the room has enemies or not
#				if enemy_grid[y][x]:
#					print("Room at (", x, ",", y, ") has enemies.")
#				else:
#					print("Room at (", x, ",", y, ") is the player spawn (no enemies).")
			else:
				print("Scene not found: ", scene_path)
	
	# Set the camera to the player's starting position
	update_camera_position()

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
		print("Player moved to room (", player_x, ",", player_y, ")")
	else:
		print("Invalid move: Player cannot move outside the grid.")

# Main function to generate and build the dungeon
func generate_dungeon():
	randomize()  # Ensure randomness
	var fully_connected = false
	
	while not fully_connected:
		fill_grid()
		match_doors()
		fully_connected = is_fully_connected()
	
	generate_enemy_grid()  # Generate the enemy grid
	#print_grid()
	build_dungeon()

# Call the main function when the script runs
func _ready():
	Inventory.disable()
	generate_dungeon()
	yield(get_tree().create_timer(2),"timeout")
	get_node("Camera2D").smoothing_enabled = true
