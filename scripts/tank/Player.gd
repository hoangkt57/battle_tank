extends "res://scripts/tank/Tank.gd"	

func _ready():
	if is_network_master():
		print("_ready - " + str(get_tree().get_network_unique_id()))
		$Camera2D.make_current()
		
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = Globals.CELL_SIZE * Globals.CELL_COUNT
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = Globals.CELL_SIZE * Globals.CELL_COUNT

func control(delta):
	velocity = Vector2()
	if is_network_master():
		if Input.is_action_pressed("ui_right"):
			velocity = Vector2(speed, 0)
			rotation_degrees = 270
		if Input.is_action_pressed("ui_left"):
			velocity = Vector2(-speed, 0)
			rotation_degrees = 90
		if Input.is_action_pressed("ui_up"):
			velocity = Vector2(0, -speed)
			rotation_degrees = 180
		if Input.is_action_pressed("ui_down"):
			velocity = Vector2(0, speed)
			rotation_degrees = 0
			
		if Input.is_action_just_pressed("ui_accept"):
			rpc("shoot", get_tree().get_network_unique_id())
		
		position.x = clamp(position.x, Globals.CELL_SIZE/2, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
		position.y = clamp(position.y, Globals.CELL_SIZE/2, Globals.CELL_SIZE * Globals.CELL_COUNT - Globals.CELL_SIZE/2)
		
		rset("puppet_velocity", velocity)
		rset("puppet_position", position)
		rset("puppet_rotation_degrees", rotation_degrees)
	
	else:
		position = puppet_position
		velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees
