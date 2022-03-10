tool
extends Position2D


export (int) var x setget _update_x
export (int) var y setget _update_y

func _update_x(_x):
	x = _x
	position = Vector2(Globals.CELL_SIZE * _x + Globals.CELL_SIZE /2, position.y)
	
func _update_y(_y):
	y = _y
	position = Vector2(position.x, Globals.CELL_SIZE * _y + Globals.CELL_SIZE /2)
