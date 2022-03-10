extends Node


var obstacles = []

func is_obstacle(direction, position):
	var pos1 = Vector2()
	var pos2 = Vector2()
	if direction.x == 0:
		pos1 = position + Globals.CELL_SIZE/2 * Vector2(1, direction.y)
		pos2 = position + Globals.CELL_SIZE/2 * Vector2(-1, direction.y)
	else:
		pos1 = position + Globals.CELL_SIZE/2 * Vector2(direction.x, -1)
		pos2 = position + Globals.CELL_SIZE/2 * Vector2(direction.x, 1)
#	print("is_obstacle - ", direction, " - ", position, " - ", pos1, " - ", pos2)
	return is_position_in_obstacle(pos1) or is_position_in_obstacle(pos2) or is_in_ground(pos1) or is_in_ground(pos2)

func is_position_in_obstacle(position):
	for obstacle in obstacles:
		if (position.x >= obstacle.x - Globals.CELL_SIZE/2 
			and position.x <= obstacle.x + Globals.CELL_SIZE/2 
			and position.y >= obstacle.y - Globals.CELL_SIZE/2
			and position.y <= obstacle.y + Globals.CELL_SIZE/2):
				return true
	return false
	
func is_in_ground(position):
	return position.x < 0 or position.y < 0 or position.x > Globals.CELL_COUNT * Globals.CELL_SIZE or position.y > Globals.CELL_COUNT * Globals.CELL_SIZE
