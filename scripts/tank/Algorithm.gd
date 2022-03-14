extends Node

const DEFAULT_VECTOR = Vector2(-1, -1)
const DEGRESS_DELTA = 3
const DEGRESS_EXTRA = 90

var delta = 0.0
var position = DEFAULT_VECTOR
var target_direction = DEFAULT_VECTOR
var target_position = DEFAULT_VECTOR
var velocity = DEFAULT_VECTOR
var has_enemy = false
var direction = DEFAULT_VECTOR
var focus_direction = DEFAULT_VECTOR
var degrees = 0
var speed = 0
var angle = 0
var rotation_degrees = 0
var player_id_focused = -1
var bot_id = -1
var need_new_cell = false
var tank_focused = null
var random = RandomNumberGenerator.new()
var result = {}


func get_detect_radius():
	pass


func clear_data():
	focus_direction = DEFAULT_VECTOR
	target_direction = DEFAULT_VECTOR
	target_position = DEFAULT_VECTOR
	player_id_focused = -1


func is_direction_has_enemy(_degress, _angle):
	return _degress - DEGRESS_DELTA <= _angle && _angle <= _degress + DEGRESS_DELTA


func direction_to_degrees(_dir, rotation_degrees):
	if _dir == Globals.DIRECTIONS[0]:
		return -90
	elif _dir == Globals.DIRECTIONS[1]:
		return 90
	elif _dir == Globals.DIRECTIONS[2]:
		return 0
	elif _dir == Globals.DIRECTIONS[3]:
		return 180
	return rotation_degrees


func degress_to_direction(_degress):
	if _degress == 0:
		return Globals.DIRECTIONS[2]
	elif _degress == 90:
		return Globals.DIRECTIONS[1]
	elif _degress == -90:
		return Globals.DIRECTIONS[0]
	elif _degress == 180:
		return Globals.DIRECTIONS[3]
	return Vector2()


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

	var distance = Vector2(
		random.randi_range(Globals.CELL_SIZE / 2, new_x),
		random.randi_range(Globals.CELL_SIZE / 2, new_y)
	)
	target_position = position + target_direction * distance
