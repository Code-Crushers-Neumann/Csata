extends Node2D

const MAX_ROOMS = 5
var room_count = 0
onready var camera = get_node("Camera2D")

# Room scenes
const ROOM_SCENES = {
	"4_doors": preload("res://scenes/rooms/Room_4ways.tscn"),
	"corridor_horizontal": preload("res://scenes/rooms/Room_corridor_leftright.tscn"),
	"corridor_vertical": preload("res://scenes/rooms/Room_corridor_updown.tscn"),
	"deadend_right": preload("res://scenes/rooms/Deadend_right.tscn"),
	"deadend_left": preload("res://scenes/rooms/Deadend_left.tscn"),
	"deadend_up": preload("res://scenes/rooms/Deadend_up.tscn"),
	"deadend_down": preload("res://scenes/rooms/Deadend_down.tscn"),
}

var generated_rooms = []
var open_doors = []

func _ready():
	# Camera setup
	camera.offset = Vector2(0, 0)
	camera.smoothing_enabled = true
	camera.smoothing_speed = 5
	camera.zoom = Vector2(35, 35)

	# Start with the spawn room
	var spawn_room = ROOM_SCENES["4_doors"].instance()
	spawn_room.position = Vector2(0, 0)
	spawn_room.id = 0
	spawn_room.finished = false
	spawn_room.doors = ["Up", "Down", "Left", "Right"]
	add_child(spawn_room)
	generated_rooms.append(spawn_room)

	for door in spawn_room.doors:
		open_doors.append({"room": spawn_room, "door": door})

	# Generate rooms
	while room_count < MAX_ROOMS - 1 and open_doors.size() > 0:
		generate_next_room()

	# Close remaining doors with dead-ends
	for connection in open_doors:
		add_deadend(connection["room"], connection["door"])

func generate_next_room():
	var connection = open_doors.pop_back()
	var current_room = connection["room"]
	var door = connection["door"]

	# Skip if the door is already connected
	if door in current_room.connected_doors:
		return

	# Randomly choose a room type
	var room_type = randi() % 3  # 0 = 4-way, 1 = horizontal, 2 = vertical
	var new_room
	if room_type == 0:
		new_room = ROOM_SCENES["4_doors"].instance()
		new_room.doors = ["Up", "Down", "Left", "Right"]
	elif room_type == 1:
		new_room = ROOM_SCENES["corridor_horizontal"].instance()
		new_room.doors = ["Left", "Right"]
	elif room_type == 2:
		new_room = ROOM_SCENES["corridor_vertical"].instance()
		new_room.doors = ["Up", "Down"]

	# Validate placement
	var offset = get_door_offset(door)
	new_room.position = current_room.position + offset
	if is_overlapping(new_room):
		new_room.queue_free()
		return

	# Mark doors as connected
	current_room.connected_doors.append(door)
	var opposite_door = get_opposite_door(door)
	new_room.connected_doors.append(opposite_door)

	# Increment room count
	room_count += 1
	generated_rooms.append(new_room)
	add_child(new_room)

	# Add remaining doors to open_doors
	for new_door in new_room.doors:
		if new_door != opposite_door:
			open_doors.append({"room": new_room, "door": new_door})

func add_deadend(current_room, door):
	var deadend_map = {
		"Right": "deadend_right",
		"Left": "deadend_left",
		"Up": "deadend_up",
		"Down": "deadend_down"
	}
	var deadend_type = deadend_map[door]
	var deadend = ROOM_SCENES[deadend_type].instance()
	deadend.id = -1
	deadend.finished = true
	deadend.doors = []
	add_child(deadend)

	var offset = get_door_offset(door)
	deadend.position = current_room.position + offset
	current_room.connected_doors.append(door)

func get_door_offset(door):
	match door:
		"Right": return Vector2(1920, 0)
		"Left": return Vector2(-1920, 0)
		"Up": return Vector2(0, -1080)
		"Down": return Vector2(0, 1080)
		_: return Vector2(0, 0)

func get_opposite_door(door):
	match door:
		"Right": return "Left"
		"Left": return "Right"
		"Up": return "Down"
		"Down": return "Up"
		_: return ""

func is_overlapping(new_room):
	for room in generated_rooms:
		if room.position == new_room.position:
			return true
	return false
