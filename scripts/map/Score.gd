extends CanvasLayer

var player_cores = {}

class MyCustomSorter:
	static func sort(a, b):
		if a["score"] > b["score"]:
			return true
		return false

func _ready():
	print("score ready")
	print(player_cores)
	for p in player_cores:
		$ItemList.add_item(get_player_score(player_cores[p]), null, false)
		
remote func increase_score(for_who):
	var pl = player_cores[for_who]
	pl.score += 1
	refresh()

func add_player(id, new_player_name):
	player_cores[id] = { name = new_player_name, score = 0 }
	
func get_player_score(player):
	return str(player.name) + " : " + str(player.score)
	
func refresh():
	var arr = player_cores.values()
	arr.sort_custom(MyCustomSorter, "sort")
	for i in arr.size():
		$ItemList.set_item_text(i, get_player_score(arr[i]))
	
