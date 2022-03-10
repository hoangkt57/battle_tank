extends Control

func _ready():
	GameState.connect("connection_failed", self, "_on_connection_failed")
	GameState.connect("connection_succeeded", self, "_on_connection_success")
	GameState.connect("player_list_changed", self, "refresh_lobby")
	GameState.connect("game_ended", self, "_on_game_ended")
	GameState.connect("game_error", self, "_on_game_error")
	
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]

func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	GameState.host_game(Globals.create_new_player(player_name, 0 , -1, -1))
	refresh_lobby()
	if GameState.is_host():
		$Players/AddBot.visible = true
		$Players/Start.visible = true
		$Players/Ready.visible = false
	
func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	GameState.join_game(Globals.create_new_player(player_name, 0 , -1, -1))

func _on_start_pressed():
		GameState.begin_game()	
		
func _on_Ready_pressed():
	var id = GameState.get_current_id()
	if not GameState.puppet_players_ready.has(id):
		$Players/Ready.text = "Cancel"
	else:
		$Players/Ready.text= "Ready"
	GameState.rpc("notify_player_ready", id)

func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")

func _on_connection_success():
	print("_on_connection_success", GameState.is_host())
	$Connect.hide()
	$Players.show()
	
func refresh_lobby():
	print(GameState.puppet_players)
	for node in $Players/ScrollContainer/List.get_children():
		node.queue_free()
	
	for id in GameState.puppet_players:
		var player = GameState.puppet_players[id]
		var item = load("res://scenes/ui/PlayerItem.tscn").instance()
		var is_ready = GameState.puppet_players_ready.has(id)
		item.set_player(id, player, is_ready)
		$Players/ScrollContainer/List.add_child(item)
	
func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	
func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false

func _on_AddBot_pressed():
	if GameState.get_player_size() > GameState.MAX_PEERS:
		$Players/AddBot.disabled = true
	else:
		$Players/AddBot.disabled = false
		GameState.create_new_bot()
		
func remove_player(node):
	var id = node.get_player_id()
	GameState.remove_player(id)

