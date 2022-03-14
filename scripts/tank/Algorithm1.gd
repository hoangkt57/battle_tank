extends "res://scripts/tank/Algorithm.gd"

var detect_radius = 800


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

#	Go To Enemy
	if player_id_focused != -1:
		tank_focused = null
		for player in players_node.get_children():
			if player.player_id == player_id_focused:
				tank_focused = player
		if tank_focused != null:
			velocity = Vector2()
			if focus_direction != DEFAULT_VECTOR:
				result.clear()
				result["rotation_degrees"] = direction_to_degrees(focus_direction, rotation_degrees)
				result["velocity"] = focus_direction * speed
				target_position = DEFAULT_VECTOR
				target_direction = DEFAULT_VECTOR
				return result
			direction = degress_to_direction(floor(tank_focused.rotation_degrees))
			var new_tank_position = tank_focused.position + direction * speed * delta
			if (
				position.distance_to(tank_focused.position)
				< position.distance_to(new_tank_position)
			):
				rotation_degrees = direction_to_degrees(direction, rotation_degrees)
				velocity = direction * speed
				focus_direction = DEFAULT_VECTOR
			else:
				var pos1 = Vector2(position.x, tank_focused.position.y)
				var pos2 = Vector2(tank_focused.position.x, position.y)
				var pos
				if position.distance_to(pos1) < position.distance_to(pos2):
					pos = pos1
				else:
					pos = pos2
				var new_direction = pos - position
				focus_direction = new_direction / abs(new_direction.x + new_direction.y)
				velocity = focus_direction * speed

			result.clear()
			result["rotation_degrees"] = rotation_degrees
			result["velocity"] = velocity
			target_position = DEFAULT_VECTOR
			target_direction = DEFAULT_VECTOR
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
