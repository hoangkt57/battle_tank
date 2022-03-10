extends GridContainer

var player_id

const ready_color = Color("#1a871c")

func _ready():
	for i in GameState.MAX_PEERS:
		$Team.add_item(str(i), i)

func set_player(_id, _player, is_ready):
	print("set_player - " + str(_id))
	player_id = _id
	$Name.text = _player.name
	$Tank.select(_player.tank)
	$Team.select(_player.team)
	$Difficulty.visible = _player.is_bot
	if _player.is_bot || is_ready:
		$Name.add_color_override("font_color", ready_color)
		
	if is_ready:
		$Tank.disabled = true
		$Difficulty.disabled = true
		$Team.disabled = true
	
	if player_id != GameState.get_current_id():
		if not GameState.is_host() || (GameState.is_host() && not _player.is_bot):
			$Tank.disabled = true
			$Difficulty.disabled = true
			$Team.disabled = true
		if GameState.is_host():
			$Remove.visible = true
	
func get_player_id():
	return player_id

func _on_Remove_pressed():
	var root = get_tree().root.get_node("Lobby")
	if root.has_method("remove_player"):
		root.remove_player(self)

func _on_Tank_item_selected(index):
	print("id - " + str(player_id) + " - index: " + str(index))
	GameState.rpc("change_tank", player_id, index)


func _on_Difficulty_item_selected(index):
	pass # Replace with function body.
