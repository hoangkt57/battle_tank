extends Node

const MAX_SPAWN_POINT_MAP_1 = 12
const DIRECTIONS = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
const CELL_SIZE = 128
const CELL_COUNT = 29
const BASE_BOT_ID = 100

enum BUFF_ITEMS {damage, health, firespeed, speed}
const BUFF_SIZE = 4
var BUFF_VALUES = {
	BUFF_ITEMS.damage: 20,
	BUFF_ITEMS.health: 30,
	BUFF_ITEMS.firespeed: 20,
	BUFF_ITEMS.speed: 20
}
		
func create_new_player(_name, _tank, _difficulty, _team):
	var is_bot = false
	if _difficulty >=0:
		is_bot = true
	return {name = _name, tank = _tank, difficulty = _difficulty, team = _team, is_bot = is_bot}
	
func create_bot_id(index):
	return BASE_BOT_ID + index

func change_player_tank(_player, _tank):
	_player["tank"] = _tank
	
func change_bot_difficulty(_player, _difficulty):
	_player["difficulty"] = _difficulty
