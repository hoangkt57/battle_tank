extends Area2D

var textures = { 
	Globals.BUFF_ITEMS.damage: preload("res://sprites/buff.png"),
	Globals.BUFF_ITEMS.health: preload("res://sprites/buff.png"),
	Globals.BUFF_ITEMS.firespeed: preload("res://sprites/buff.png"),
	Globals.BUFF_ITEMS.speed: preload("res://sprites/buff.png")
}

var type

func random_type():
	return randi() % Globals.BUFF_SIZE

func set_type(_position):
	type = random_type()
	$Sprite.texture = textures[type]
	var rect = RectangleShape2D.new()
	rect.extents = $Sprite.get_rect().size / 2
	$CollisionShape2D.shape = rect
	
	position = _position
	$PickUpAppear.play()

func _on_PickUp_body_entered(body):
	if body.has_method('pick_up_buff'):
		body.pick_up_buff(type)
	queue_free()
