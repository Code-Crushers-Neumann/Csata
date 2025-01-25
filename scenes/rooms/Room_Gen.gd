extends Node2D

var id = [0,0]
var enemies = []

var allpos = [Vector2(200,200),Vector2(600,200),Vector2(1000,200), Vector2(1400,200), Vector2(200,540),Vector2(600,540),Vector2(1000,540),Vector2(1400,540),Vector2(200,880),Vector2(600,880),Vector2(1000,880),Vector2(1400,880)]
var TopExcl = [allpos[1],allpos[2]]
var LeftExcl = [allpos[4] , allpos[5]]
var BottomExcl = [allpos[9], allpos[10]]
var RightExcl = [allpos[6] , allpos[7]]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func initiate(var _name,var _id, var spawning):
	var szin = Color8((randi() % 156)+50,(randi() % 156)+50,(randi() % 156)+50)
	if(spawning):
		var directions = _name.split('_')
		if directions.has("Up"):
			for adat in TopExcl:
				allpos.erase(adat)
		if directions.has("Down"):
			for adat in BottomExcl:
				allpos.erase(adat)
		if directions.has("Left"):
			for adat in LeftExcl:
				allpos.erase(adat)
		if directions.has("Right"):
			for adat in RightExcl:
				allpos.erase(adat)
		var nodelocal = self.position
		var voltman = []
		for i in rand_range(1,allpos.size()-1):
			var currentpos = choose(allpos)
			if!(currentpos in voltman):
				var spawn = nodelocal + allpos[i]
				var newenemy_scene = load("res://scenes/enemy/enemy_1.tscn")
				var newenemy = newenemy_scene.instance()
				newenemy.position = spawn
				add_child(newenemy)
				voltman.append(currentpos)

		#for adat in allpos:
		#	var spawn = nodelocal + adat
		#	var newenemy_scene = load("res://scenes/enemy/enemy_1.tscn")
		#	var newenemy = newenemy_scene.instance()
		#	newenemy.position = spawn
		#	add_child(newenemy)

	else:
		allpos = []
	#print(_id)
	#print(allpos)
	id = _id
	var szinarray = generate_analogous_colors(szin)
	get_node("Wall").modulate = szin
	get_node("Floor").modulate = szinarray[2]
	get_node("Wall").texture = load("res://images/walls/"+choose(["1","2","3"])+"/"+_name+".png")
	get_node("Floor").texture = load("res://images/floors/"+choose(["1","2","3"])+".png")
	for adat in _name.split('_'):
		get_node("ToOpen/"+adat).queue_free()

func choose(array):
	return array[randi() % array.size()]
	

# Function to convert HSV to RGB
func hsv_to_rgb(h: float, s: float, v: float) -> Color:
	var c = v * s
	var x = c * (1 - abs(fmod(h * 6, 2.0) - 1))
	var m = v - c
	var rgb = Color()

	if h < 1.0 / 6.0:
		rgb = Color(c, x, 0)
	elif h < 2.0 / 6.0:
		rgb = Color(x, c, 0)
	elif h < 3.0 / 6.0:
		rgb = Color(0, c, x)
	elif h < 4.0 / 6.0:
		rgb = Color(0, x, c)
	elif h < 5.0 / 6.0:
		rgb = Color(x, 0, c)
	else:
		rgb = Color(c, 0, x)

	rgb.r += m
	rgb.g += m
	rgb.b += m

	return rgb

# Function to generate analogous colors
func generate_analogous_colors(base_color: Color, num_colors: int = 3, spread: float = 30.0) -> Array:
	var analogous_colors = []
	var hsv = rgb_to_hsv(base_color)  # Convert RGB to HSV
	var hue = hsv[0]
	var saturation = hsv[1]
	var value = hsv[2]

	for i in range(num_colors):
		var offset = (i - (num_colors - 1) / 2.0) * (spread / 360.0)
		var new_hue = fmod(hue + offset + 1.0, 1.0)  # Ensure hue stays within [0, 1]
		var new_color = hsv_to_rgb(new_hue, saturation, value)
		analogous_colors.append(new_color)

	return analogous_colors

# Function to convert RGB to HSV
func rgb_to_hsv(color: Color) -> Array:
	var r = color.r
	var g = color.g
	var b = color.b

	var max_val = max(r, max(g, b))
	var min_val = min(r, min(g, b))
	var delta = max_val - min_val

	var h = 0.0
	var s = 0.0
	var v = max_val

	if delta != 0:
		s = delta / max_val

		if max_val == r:
			h = fmod((g - b) / delta, 6.0) / 6.0
		elif max_val == g:
			h = ((b - r) / delta + 2.0) / 6.0
		elif max_val == b:
			h = ((r - g) / delta + 4.0) / 6.0

		if h < 0:
			h += 1.0

	return [h, s, v]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	print(id)
	if(body.name == "test_player"):
		get_parent().move_player(id[1],id[0])
