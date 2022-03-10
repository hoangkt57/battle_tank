tool
extends StaticBody2D

enum Items {treeBrown_large, treeBrown_small, treeGreen_large, treeGreen_small}

var textures = {
	Items.treeBrown_large: preload("res://sprites/treeBrown_large.png"),
	Items.treeBrown_small: preload("res://sprites/treeBrown_small.png"),
	Items.treeGreen_large: preload("res://sprites/treeGreen_large.png"),
	Items.treeGreen_small: preload("res://sprites/treeGreen_small.png")
}

export (Items) var type setget _update
export (int) var x setget _update_x
export (int) var y setget _update_y

func _update_x(_x):
	x = _x
	position = Vector2(Globals.CELL_SIZE * _x + Globals.CELL_SIZE /2, position.y)
	
func _update_y(_y):
	y = _y
	position = Vector2(position.x, Globals.CELL_SIZE * _y + Globals.CELL_SIZE /2)

func _update(_type):
	type = _type
	if !Engine.editor_hint:
		yield(self, 'tree_entered')
	$Sprite.texture = textures[type]
	var rect = RectangleShape2D.new()
	rect.extents = $Sprite.get_rect().size / 2
	$CollisionShape2D.shape = rect

