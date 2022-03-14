extends "res://scripts/tank/Tank.gd"

var random = RandomNumberGenerator.new()

var algorithm = null

func _ready():
	if difficulty == 2:
		algorithm = load("res://scripts/tank/Algorithm1.gd").new()
	else:
		algorithm = load("res://scripts/tank/Algorithm2.gd").new()
	print("bot ready - ", difficulty, " - ", algorithm.get_detect_radius())
	var circle = CircleShape2D.new()
	$DetectRadius/CollisionShape2D.shape = circle
	$DetectRadius/CollisionShape2D.shape.radius = algorithm.get_detect_radius()

func respawn_value():
	algorithm.clear_data()

func control(delta):
#	velocity = Vector2()
#	return
	if GameState.is_host():
		
		
		var players_node = get_parent()
		var data = {}
		data["delta"] = delta
		data["position"] = position
		data["rotation_degrees"] = rotation_degrees
		data["speed"] = speed
		data["bot_id"] = player_id
		
		var result = algorithm.control(players_node, data)
		var old_rotation_degrees = rotation_degrees
		rotation_degrees = result["rotation_degrees"]
		velocity = result["velocity"]	
		rset("puppet_velocity", velocity)
		rset("puppet_rotation_degrees", rotation_degrees)
		if result.has("position"):
			position = result["position"]
		rset("puppet_position", position)
		if result.has("should_shoot") and result["should_shoot"]:
			if abs(floor(old_rotation_degrees)) != abs(rotation_degrees):
#				print("haizzzzzzzzzzzzzzzzzz - ", abs(floor(old_rotation_degrees)) , " - ",  abs(rotation_degrees))
				yield(get_tree().create_timer(1.5), "timeout")
			var dir = Vector2(0,1).rotated($Turret.global_rotation)
			rpc("shoot", player_id, dir)
	else:
		position = puppet_position
		velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees


func _on_DetectRadius_Tank_entered(body):
#	print("_on_DetectRadius_Tank_entered - ", body, " - ", player_id_focused)
	if body is KinematicBody2D and body != self and algorithm.player_id_focused == -1:
		algorithm.player_id_focused = body.player_id


func _on_DetectRadius_Tank_exited(body):
#	print("_on_DetectRadius_Tank_exited - ", body)
	if body is KinematicBody2D and algorithm.player_id_focused == body.player_id:
		algorithm.player_id_focused = -1
