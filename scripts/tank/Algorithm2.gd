extends "res://scripts/tank/Algorithm.gd"

var detect_radius = 0


func get_detect_radius():
	return detect_radius


func control(players_node, data):
	delta = data["delta"]
	position = data["position"]
	rotation_degrees = data["rotation_degrees"]
	speed = data["speed"]
	bot_id = data["bot_id"]
	has_enemy = false
	direction = Vector2()
	degrees = 0
	need_new_cell = target_direction == DEFAULT_VECTOR

#	Shoot Enemy
	for player in players_node.get_children():
		if player.player_id != bot_id:
			if position.distance_to(player.position) > 896:
				continue
			angle = rad2deg((player.position - position).angle())
			var test = player.position
			if is_direction_has_enemy(0, angle):
				direction = Globals.DIRECTIONS[0]
				has_enemy = true
			elif is_direction_has_enemy(180, angle):
				direction = Globals.DIRECTIONS[1]
				has_enemy = true
			elif is_direction_has_enemy(90, angle):
				direction = Globals.DIRECTIONS[2]
				has_enemy = true
			elif is_direction_has_enemy(-90, angle):
				direction = Globals.DIRECTIONS[3]
				has_enemy = true
			if has_enemy:
				break

	if has_enemy:
		velocity = Vector2()
		result.clear()
		result["rotation_degrees"] = direction_to_degrees(direction, rotation_degrees)
		result["velocity"] = direction * speed
		result["should_shoot"] = true
		target_position = DEFAULT_VECTOR
		target_direction = DEFAULT_VECTOR
		focus_direction = DEFAULT_VECTOR
		return result

	if target_direction.x == 0:
		if target_direction.y >= 0:
			position.y = clamp(position.y, Globals.CELL_SIZE / 2, target_position.y)
		else:
			position.y = clamp(
				position.y,
				target_position.y,
				Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE / 2
			)
	elif target_direction.y == 0:
		if target_direction.x >= 0:
			position.x = clamp(position.x, Globals.CELL_SIZE / 2, target_position.x)
		else:
			position.x = clamp(
				position.x,
				target_position.x,
				Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE / 2
			)

	if (
		target_direction == DEFAULT_VECTOR
		or (target_direction.x != 0 and position.x == target_position.x)
		or (target_direction.y != 0 and position.y == target_position.y)
	):
		need_new_cell = true
	elif MapUtils.is_obstacle(target_direction, position + target_direction * speed * delta):
		need_new_cell = true

	if need_new_cell:
		random_target_cell(delta)

	focus_direction = DEFAULT_VECTOR

	if target_direction != DEFAULT_VECTOR:
		velocity = Vector2()
		velocity = target_direction * speed
		rotation_degrees = direction_to_degrees(target_direction, rotation_degrees)

	position.x = clamp(
		position.x,
		Globals.CELL_SIZE / 2,
		Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE / 2
	)
	position.y = clamp(
		position.y,
		Globals.CELL_SIZE / 2,
		Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE / 2
	)

	result.clear()
	result["rotation_degrees"] = rotation_degrees
	result["velocity"] = velocity
	result["position"] = position
	return result
