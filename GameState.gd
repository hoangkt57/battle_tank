extends Node

const DEFAULT_PORT = 10567
const DEFAULT_IP = "127.0.0.1"
const MAX_PEERS = 6

var peer = null
var bot_index = 0
var player = null
puppet var puppet_players = {}
puppet var puppet_players_ready = {}

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _player_connected(id):
	rpc_id(id, "register_player", player)
	
func _player_disconnected(id):
	if has_node("/root/Map"):
		if get_tree().is_network_server():
			emit_signal("game_error", "Player ", puppet_players[id], " disconnected")
			end_game()
	else:
		remove_player(id)

func _connected_ok():
	emit_signal("connection_succeeded")
	
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")
	
remotesync func notify_player_change():
	emit_signal("player_list_changed")
	
remote func register_player(new_player):
	var id = get_tree().get_rpc_sender_id()
	if is_host():
		print("register_player - id: " + str(id) + " - " + str(new_player))
		add_player_to_list(id, new_player)
	
func end_game():
	if has_node("/root/Map"):
		get_node("/root/Map").queue_free()

	emit_signal("game_ended")
	puppet_players.clear()

func host_game(new_player):
	player = new_player
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	puppet_players[get_current_id()] = new_player
	
func join_game(new_player):
	player = new_player
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
	
func get_player_size():
	return puppet_players.size()

func get_current_id():
	return get_tree().get_network_unique_id()

func is_host():
	return get_tree().root.is_network_master()
		
func begin_game():
	assert(get_tree().is_network_server())

	var random = RandomNumberGenerator.new()
	random.randomize()
	var spawn_points = {}
	var arr = []
	for i in range(0, Globals.MAX_SPAWN_POINT_MAP_1):
		arr.append(i)
	for key in puppet_players:
		var index = random.randi_range(0, arr.size() - 1)
		spawn_points[key] = arr[index]
		arr.remove(index)
	rpc("pre_start_game", spawn_points)
	
remotesync func pre_start_game(spawn_points):
	print("pre_start_game - " + str(spawn_points))
	var map = load("res://scenes/map/Map.tscn").instance()
	for p_id in spawn_points:
		map.get_node("Score").add_player(p_id, puppet_players[p_id].name)
	
	get_tree().get_root().add_child(map)
	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://scenes/tank/Player.tscn")
	var bot_scene = load("res://scenes/tank/BotTank.tscn")

	for p_id in spawn_points:
		var spawn_pos = map.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		
		var item = puppet_players[p_id]
		if item.is_bot:
			var bot_ins = bot_scene.instance()
			bot_ins.set_name(str(p_id))
			bot_ins.position=spawn_pos
			bot_ins.set_player(p_id, item)
			map.get_node("Players").add_child(bot_ins)
		else:
			var player_ins = player_scene.instance()
			player_ins.set_name(str(p_id))
			player_ins.position=spawn_pos
			player_ins.set_network_master(p_id)
			player_ins.set_player(p_id, item)
			map.get_node("Players").add_child(player_ins)

	rpc("post_start_game")
		
remotesync func post_start_game():
	get_tree().set_pause(false) 
	
func create_new_bot():
	bot_index += 1
	var bot = Globals.create_new_player("Bot " + str(bot_index), 0, 0, -1)
	var bot_id = Globals.create_bot_id(bot_index)
	add_player_to_list(bot_id, bot)
	
func remove_player(_id):
	add_or_remove_player_to_list(_id, null, false)
	
func add_player_to_list(_id, _player):
	add_or_remove_player_to_list(_id, _player, true)

func add_or_remove_player_to_list(_id, _player, is_add):
	if is_add:
		puppet_players[_id] = _player
	else: 
		puppet_players.erase(_id)
	rset("puppet_players", puppet_players)
	rpc("notify_player_change")

remotesync func notify_player_ready(_id):
	if not is_host():
		return
	if not puppet_players_ready.has(_id):
		add_or_remove_player_ready_to_list(_id, true)
	else:
		add_or_remove_player_ready_to_list(_id, false)	
	
func add_or_remove_player_ready_to_list(_id, is_add):
	if is_add:
		puppet_players_ready[_id] = true
	else:
		puppet_players_ready.erase(_id)
	rset("puppet_players_ready", puppet_players_ready)
	rpc("notify_player_change")

remotesync func change_tank(_id, _tank):
	if not is_host():
		return
	if not puppet_players.has(_id):
		print("change_tank - " + str(_id) + " is not exists")
		return
	var value = puppet_players[_id]
	Globals.change_player_tank(value, _tank)
	add_player_to_list(_id, value)
	
	
	
	
	
