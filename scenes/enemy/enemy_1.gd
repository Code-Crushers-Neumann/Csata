extends KinematicBody2D

var speed = 100

var inside_player = false

onready var player = get_tree().get_root().get_child(15).get_node("test_player")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().enemies.append(self)

func die():
	self.set_physics_process(false)
	speed = 0
	get_parent().enemies.erase(self)
	if(get_parent().enemies.empty()):
		get_tree().get_root().get_child(15).enemy_grid[get_parent().id[0]][get_parent().id[1]] = false
		if are_all_elements_false(get_tree().get_root().get_child(15).enemy_grid):
			get_tree().get_root().get_child(15).get_node("test_player").queue_free()
	#print(get_tree().get_root().get_child(15).enemy_grid)
	get_node("CollisionShape2D/AnimatedSprite").play("dead")
	for i in 255:
		yield(get_tree().create_timer(0.0078125),"timeout")
		self.modulate = Color8(self.modulate.r8,self.modulate.g8,self.modulate.b8,self.modulate.a8-1)
	self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_instance_valid(player):
		if(player.get_parent().player_x == get_parent().id[1] && player.get_parent().player_y == get_parent().id[0]):
			self.move_and_slide((player.global_position-global_position).normalized()*speed)
		if player in get_node("Area2D").get_overlapping_bodies():
			if player.can_take_damage && self.modulate == Color8(255,255,255,255):
				player.can_take_damage = false
				player.get_node("DamageCooldownTimer").start()
				player.set_health(player.health-1)

func are_all_elements_false(arr: Array) -> bool:
	for sub_array in arr:  # Iterate through each sub-array
		for element in sub_array:  # Iterate through each element in the sub-array
			if element:
				return false  # If any element is true, return false
	return true  # All elements in all sub-arrays are false



func _on_Area2D_body_entered(body:Node):
	if "player" in body.name:
		inside_player = true

func _on_Area2D_body_exited(body:Node):
	if "player" in body.name:
		inside_player = true
