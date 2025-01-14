extends Node2D

const MAX_ROOMS = 1  # Set to 5 for testing purposes
var room_count = 0
onready var camera = get_node("Camera2D")

# Room scenes
const ROOM_SCENES = {
	"4_doors": preload("res://scenes/rooms/Room_4ways.tscn"),
	"deadend_right": preload("res://scenes/rooms/Deadend_right.tscn"),
	"deadend_left": preload("res://scenes/rooms/Deadend_left.tscn"),
	"deadend_up": preload("res://scenes/rooms/Deadend_up.tscn"),
	"deadend_down": preload("res://scenes/rooms/Deadend_down.tscn"),
}

var generated_rooms = []
var open_doors = []  # Track unconnected doors

func _ready():
	# Set the camera to follow the player smoothly
	camera.offset = Vector2(0, 0)  # Adjust this to change the camera's offset
	camera.smoothing_enabled = true  # Enable smoothing for smooth camera movement
	camera.smoothing_speed = 5  # Adjust speed for smoothing

	# Set the zoom level (optional)
	camera.zoom = Vector2(50, 50)  # Zoom out to fit the dungeon

	# Set camera limits to ensure it doesn't go out of bounds
	# Start with the spawn room
	var spawn_room = ROOM_SCENES["4_doors"].instance()
	spawn_room.position = Vector2(0, 0)
	spawn_room.id = 0
	spawn_room.finished = false
	spawn_room.doors = ["Up", "Down", "Left", "Right"]
	add_child(spawn_room)
	generated_rooms.append(spawn_room)

	# Add its doors to the open_doors list
	for door in spawn_room.doors:
		open_doors.append({"room": spawn_room, "door": door})

	# Start generation
	while room_count < MAX_ROOMS - 1 and open_doors.size() > 0:
		generate_next_room()

	# Close all remaining doors with dead-ends
	for connection in open_doors:
		add_deadend(connection["room"], connection["door"])
	
	#printerr(room_count)

func generate_next_room():
	# Pick a random open door
	var connection = open_doors.pop_back()
	var current_room = connection["room"]
	var door = connection["door"]

	# Skip if the door is already connected
	if door in current_room.connected_doors:
		return

	# Create a new room
	var new_room = ROOM_SCENES["4_doors"].instance()  # You can randomize this if needed
	new_room.id = room_count + 1
	new_room.finished = false
	new_room.doors = ["Up", "Down", "Left", "Right"]
	add_child(new_room)

	# Position the new room relative to the current room's door
	var offset = get_door_offset(door)
	new_room.position = current_room.position + offset

	# Mark the doors as connected
	current_room.connected_doors.append(door)
	var opposite_door = get_opposite_door(door)
	new_room.connected_doors.append(opposite_door)

	# Increment room count and add new room's doors to open_doors
	room_count += 1
	generated_rooms.append(new_room)
	for new_door in new_room.doors:
		if new_door != opposite_door:  # Skip the door already connected
			open_doors.append({"room": new_room, "door": new_door})


func add_deadend(current_room, door):
	# Add a dead-end room
	# Map door direction to dead-end type
	var deadend_map = {
		"Right": "deadend_right",
		"Left": "deadend_left",
		"Up": "deadend_up",
		"Down": "deadend_down"
	}
	var deadend_type = deadend_map[door]
	var deadend = ROOM_SCENES[deadend_type].instance()
	deadend.id = -1  # Dead-ends can have a special ID
	deadend.finished = true
	deadend.doors = []
	add_child(deadend)

	# Position the dead-end
	var offset = get_door_offset(door)
	deadend.position = current_room.position + offset

	# Mark the door as connected
	current_room.connected_doors.append(door)  # Directly append to the connected_doors array

func get_door_offset(door):
	# Return the position offset based on the door's direction
	match door:
		"Right":
			return Vector2(1920, 0)
		"Left":
			return Vector2(-1920, 0)
		"Up":
			return Vector2(0, -1080)
		"Down":
			return Vector2(0, 1080)
		_:
			return Vector2(0, 0)  # Default case if no match is found

func get_opposite_door(door):
	# Return the opposite direction of the given door
	match door:
		"Right":
			return "Left"
		"Left":
			return "Right"
		"Up":
			return "Down"
		"Down":
			return "Up"
		_:
			return ""  # Default case if no match is found
