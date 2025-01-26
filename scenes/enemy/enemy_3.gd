extends KinematicBody2D

onready var player = get_tree().get_root().get_child(15).get_node("test_player")
export var speed: float = 200.0
export var min_distance: float = 375.0
export var max_distance: float = 500.0

var velocity: Vector2 = Vector2.ZERO
var shoot_timer: float = 0.0
var bullet_scene = load("res://scenes/bullets/bullet_normal.tscn")  # Load the bullet scene

func _ready():
	get_parent().enemies.append(self)

func die():
	self.set_physics_process(false)
	speed = 0
	get_parent().enemies.erase(self)
	if get_parent().enemies.empty():
		get_tree().get_root().get_child(15).enemy_grid[get_parent().id[0]][get_parent().id[1]] = false
		if are_all_elements_false(get_tree().get_root().get_child(15).enemy_grid):
			get_parent().get_parent().reset_dungeon()
	get_node("CollisionShape2D/AnimatedSprite").play("dead")
	for i in 255:
		yield(get_tree().create_timer(0.0078125), "timeout")
		self.modulate = Color8(self.modulate.r8, self.modulate.g8, self.modulate.b8, self.modulate.a8 - 1)
	self.queue_free()

func _physics_process(delta):
	if is_instance_valid(player):
		if player.get_parent().player_x == get_parent().id[1] && player.get_parent().player_y == get_parent().id[0]:
			# Calculate the direction to the player
			var direction_to_player = global_position.direction_to(player.global_position)
			var distance_to_player = global_position.distance_to(player.global_position)

			# Adjust velocity based on distance
			if distance_to_player < min_distance:
				# Move away from the player
				velocity = -direction_to_player * speed
			elif distance_to_player > max_distance:
				# Move toward the player
				velocity = direction_to_player * speed
			else:
				# Smoothly stop moving if within the desired range
				velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)

			# Move the enemy
			velocity = move_and_slide(velocity)

			# Handle collisions (e.g., walls or corners)
			if is_stuck():
				try_escape()

			# Shooting logic
			shoot_timer += delta
			if shoot_timer >= 3.0:  # Shoot every 3 seconds
				shoot_timer = 0.0
				shoot_at_player()

		if player in get_node("Area2D").get_overlapping_bodies():
			if player.can_take_damage && self.modulate == Color8(255, 255, 255, 255):
				player.can_take_damage = false
				player.get_node("DamageCooldownTimer").start()
				player.set_health(player.health - 1)

func are_all_elements_false(arr: Array) -> bool:
	for sub_array in arr:
		for element in sub_array:
			if element:
				return false
	return true

func is_stuck() -> bool:
	# Check if the enemy's velocity is negligible (stuck in a wall or corner)
	return velocity.length() < 10.0

func try_escape():
	# Try moving in random directions to escape
	var escape_directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for dir in escape_directions:
		var new_velocity = dir * speed
		new_velocity = move_and_slide(new_velocity)
		if new_velocity.length() > 10.0:  # Check if the enemy is no longer stuck
			velocity = new_velocity
			break

func shoot_at_player():
	#print("Shooting at player!")  # Debugging line
	if is_instance_valid(player):
		# Predict player's future position
		var player_velocity = player.velocitytoother  # Assuming the player has a `velocity` variable
		var prediction_time = 0.0  # Predict 1 second into the future
		var predicted_position = player.global_position + player_velocity * prediction_time

		# Calculate direction to the predicted position
		var direction_to_predicted = global_position.direction_to(predicted_position)

		# Spawn a bullet
		var bullet = bullet_scene.instance()
		bullet.global_position = global_position
		bullet.direction = direction_to_predicted  # Set the direction
		get_parent().get_parent().add_child(bullet)
		#print("Bullet spawned at: ", bullet.global_position)  # Debugging line
