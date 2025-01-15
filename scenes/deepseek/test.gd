extends Node2D

# Define the possible directions
var directions = ["Up", "Down", "Left", "Right"]

# Define the opposite directions
var opposite = {"Up": "Down", "Down": "Up", "Left": "Right", "Right": "Left"}

# Grid dimensions (can be changed)
var grid_width = 5 # Example: 3 columns
var grid_height = 5 # Example: 2 rows

# Initialize the grid dynamically
var grid = []

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

# Print the resulting grid
func print_grid():
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(grid[y][x])
		print(row)

# Main function to generate the dungeon
func generate_dungeon():
	randomize()  # Ensure randomness
	fill_grid()
	match_doors()
	print_grid()

# Call the main function when the script runs
func _ready():
	generate_dungeon()
