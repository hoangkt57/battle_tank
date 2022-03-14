extends Node2D

func _ready():
	for node in $Obstacles.get_children():
		MapUtils.obstacles.append(node.position)
		print(node.position)
	$FirstStart.play()
	if GameState.is_host():
		$Timer.wait_time = 3
		$Timer.start()

func _on_Timer_timeout():
	rpc("create_buff", random_position())
	
remotesync func create_buff(_position):
	var item = load("res://scenes/map/PickUp.tscn").instance()
	item.set_type(_position)
	add_child(item)
	
func random_position():
	var random = RandomNumberGenerator.new()
	random.randomize()
	var x = random.randi_range(Globals.CELL_SIZE, Globals.CELL_SIZE * (Globals.CELL_COUNT - 1))
	var y = random.randi_range(Globals.CELL_SIZE, Globals.CELL_SIZE * (Globals.CELL_COUNT - 1))
	return Vector2(x, y)
	
func _physics_process(delta):
	if Input.is_action_pressed("ui_focus_next"):
		if not $Board/ItemList.is_visible():
			$Board/ItemList.clear()
			for player in $Players.get_children():
				var info = {}
				info["speed"] = player.speed
				info["bullet_damage"] = player.bullet_damage
				info["bullet_speed"] = player.bullet_speed
				info["health"] = player.health
				$Board/ItemList.add_item(str(player.get_player_name() + " : " + str(info)))
			$Board/ItemList.visible = true
	else:
		$Board/ItemList.visible = false
