extends "res://scripts/tank/Tank.gd"

const DEGRESS_DELTA = 3
const DEGRESS_EXTRA = 90

const DEFAULT_VECTOR = Vector2(-1, -1)

var target_position = DEFAULT_VECTOR
var target_direction = DEFAULT_VECTOR
var focus_direction = DEFAULT_VECTOR
var detect_radius = 800

var random = RandomNumberGenerator.new()

var player_id_focused = -1

func _ready():
	$DetectRadius/CollisionShape2D.shape.radius = detect_radius

func respawn_value():
	target_position = DEFAULT_VECTOR
	target_direction = DEFAULT_VECTOR
	focus_direction = DEFAULT_VECTOR
	player_id_focused = -1

func is_direction_has_enemy(_degress, _angle):
	return _degress - DEGRESS_DELTA <= _angle && _angle <= _degress + DEGRESS_DELTA

func get_cell():
	return (position / Globals.CELL_SIZE).floor()
	
func calculate_distance_to_edge(_position, _direction):
	if _direction > 0:
		return Globals.CELL_SIZE * Globals.CELL_COUNT - _position - Globals.CELL_SIZE / 2
	elif _direction < 0:
		return _position
	return 0

func random_target_cell(_delta):
	var direction_available = []
	random.randomize()
	
	for dir in Globals.DIRECTIONS:
		if not MapUtils.is_obstacle(dir, position + dir * speed * _delta):
			direction_available.append(dir)
	
	if direction_available.size() == 0:
		return
	
	var index_dir = random.randi_range(0, direction_available.size() - 1)	
	target_direction = direction_available[index_dir]
	
	var new_x = calculate_distance_to_edge(position.x, target_direction.x)
	var new_y = calculate_distance_to_edge(position.y, target_direction.y)
	
	var distance = Vector2(random.randi_range(Globals.CELL_SIZE / 2, new_x), random.randi_range(Globals.CELL_SIZE / 2, new_y))
	target_position = position + target_direction * distance
	
func direction_to_degrees(_dir):
	if _dir == Globals.DIRECTIONS[0]:
		return -90
	elif _dir == Globals.DIRECTIONS[1]:
		return 90
	elif _dir == Globals.DIRECTIONS[2]:
		return 0
	elif _dir == Globals.DIRECTIONS[3]:
		return -180
	return rotation_degrees
	
func degress_to_direction(_degress):
	if _degress == 0:
		return Globals.DIRECTIONS[2]
	elif _degress == 90:
		return Globals.DIRECTIONS[1]
	elif _degress == -90:
		return Globals.DIRECTIONS[0]
	elif _degress == -180:
		return Globals.DIRECTIONS[3]
	return Vector2()

func control(delta):
#	if player_id == 101:
#		for player in get_parent().get_children():
#			print(player, " - ", player.position)
#			pass
	
	
#	velocity = Vector2() 
#	return
	if GameState.is_host():
		var players_node = get_parent()
		var has_enemy = false
		var direction = Vector2()
		var degrees = 0
		var need_new_cell = target_direction == DEFAULT_VECTOR
		
#		Shoot Enemy
		for player in players_node.get_children():
			if player != self:
				if position.distance_to(player.position) > 896:
					continue
				var angle = rad2deg((player.position - position).angle())
#				print("angle - ", angle)
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
#			print("has_enemy - ", direction)
			rotation_degrees = direction_to_degrees(direction)
			velocity = Vector2()
			velocity = direction * speed
			target_position = DEFAULT_VECTOR
			target_direction = DEFAULT_VECTOR
			focus_direction = DEFAULT_VECTOR
			rset("puppet_velocity", velocity)
			rset("puppet_position", position)
			rset("puppet_rotation_degrees", rotation_degrees)
			rpc("shoot", player_id)
			return

#		Go To Enemy
		if player_id_focused != -1:
			var tank_focused = null
			for player in players_node.get_children():
				if player.player_id == player_id_focused:
					tank_focused = player
			if tank_focused != null:
				velocity = Vector2()
				if focus_direction != DEFAULT_VECTOR:
					rotation_degrees = direction_to_degrees(focus_direction)
					velocity = focus_direction * speed
					return
				direction = degress_to_direction(floor(tank_focused.rotation_degrees))
				var new_tank_position = tank_focused.position + direction * speed * delta
#				print("haizz - ", tank_focused.position," - ", new_tank_position, " - ",direction)
#				print("distance - ", position.distance_to(tank_focused.position), " - ", position.distance_to(new_tank_position))
				if position.distance_to(tank_focused.position) < position.distance_to(new_tank_position):
					rotation_degrees = direction_to_degrees(direction)
					velocity = direction * speed
				else:
					var pos1 = Vector2(position.x, tank_focused.position.y)
					var pos2 = Vector2(tank_focused.position.x, position.y)
					var pos
					if position.distance_to(pos1) < position.distance_to(pos2):
						pos = pos1
					else: 
						pos = pos2
					var new_direction = pos - position
					focus_direction = new_direction/ abs(new_direction.x + new_direction.y)
					velocity = focus_direction * speed
					
				target_position = DEFAULT_VECTOR
				target_direction = DEFAULT_VECTOR
				return

		if target_direction.x == 0:
			if target_direction.y >= 0:
				position.y = clamp(position.y, Globals.CELL_SIZE/2, target_position.y)
			else:
				position.y = clamp(position.y, target_position.y, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
		elif target_direction.y == 0:
			if target_direction.x >= 0:
				position.x = clamp(position.x, Globals.CELL_SIZE/2, target_position.x)
			else:
				position.x = clamp(position.x, target_position.x, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
			
#		print("haizzzzzzzzzzzzz - ", target_direction, " - ", target_position, " - ", position, " - ", speed * delta)
		
		
		if target_direction == DEFAULT_VECTOR or (target_direction.x != 0 and position.x == target_position.x) or (target_direction.y != 0 and position.y == target_position.y):
			need_new_cell = true
		elif MapUtils.is_obstacle(target_direction, position + target_direction * speed * delta):
			need_new_cell = true
		
		if need_new_cell:
			random_target_cell(delta)
			focus_direction = DEFAULT_VECTOR
			
		if target_direction == DEFAULT_VECTOR:
			print("haizzzzzz ", position)
		
		if target_direction != DEFAULT_VECTOR:
			velocity = Vector2() 
			velocity = target_direction * speed
			rotation_degrees = direction_to_degrees(target_direction)
		
		position.x = clamp(position.x, Globals.CELL_SIZE/2, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
		position.y = clamp(position.y, Globals.CELL_SIZE/2, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
		
		rset("puppet_velocity", velocity)
		rset("puppet_position", position)
		rset("puppet_rotation_degrees", rotation_degrees)
	else:
		position = puppet_position
		velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees


func _on_DetectRadius_Tank_entered(body):
#	print("_on_DetectRadius_Tank_entered - ", body, " - ", player_id_focused)
	if body is KinematicBody2D and body != self and player_id_focused == -1:
		player_id_focused = body.player_id


func _on_DetectRadius_Tank_exited(body):
#	print("_on_DetectRadius_Tank_exited - ", body)
	if body is KinematicBody2D and player_id_focused == body.player_id:
		player_id_focused = -1
