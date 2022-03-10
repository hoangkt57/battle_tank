extends Node2D


func _ready():
	for node in $Obstacles.get_children():
		MapUtils.obstacles.append(node.position)
		print(node.position)
	$FirstStart.play()
	$Timer.wait_time = 3
	$Timer.start()

func _on_Timer_timeout():
	var item = load("res://scenes/map/PickUp.tscn").instance()
	item.set_type()
	add_child(item)
