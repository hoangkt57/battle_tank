extends KinematicBody2D

signal shoot
signal dead

var speed = 200
var gun_cooldown = 0.4
var max_health = 100
var bullet_speed = 750
var bullet_damage = 40
var bullet_life_time = 1.2

const SHIELD_TIME = 3

var bar_red = preload("res://sprites/barHorizontal_red_mid 200.png")
var bar_green = preload("res://sprites/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://sprites/barHorizontal_yellow_mid 200.png")
var bullet = preload("res://scenes/bullet/Bullet.tscn")

var velocity = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_position = Vector2()
puppet var puppet_rotation_degrees = 0
var can_shoot = true
var alive = true
var enable_shield = false
var health
var bar_texture
var player_id
var is_bot

func _ready():
	health = max_health
	health_change()
	$Timer.wait_time = gun_cooldown
	$ShieldTimer.wait_time = SHIELD_TIME
	enable_shield()
	
func control(delta):
	pass
	
func _physics_process(delta):
	if not alive:
		return
	control(delta)
	move_and_slide(velocity)
#	if not is_network_master():
#		puppet_position = position
	
remotesync func shoot(by_who):
	if not can_shoot:
		return
	can_shoot = false
	$Timer.start()
	var dir = Vector2(0,1).rotated($Turret.global_rotation)
	$AnimationPlayer.play('fire')
	if by_who == GameState.get_current_id():
		$ShootAudio.play()
	
	var b = bullet.instance()
	b.set_config(by_who, bullet_speed, bullet_damage, bullet_life_time)
	get_node("../..").add_child(b)
	b.start($Turret/Muzzle.global_position, dir, $Body.frame)

func explode(by_who):
	alive = false
	can_shoot = false
	$Body.hide()
	$Turret.hide()
	$Explosion.show()
	$Explosion.play("destroy")
	if by_who == GameState.get_current_id() or player_id == GameState.get_current_id():
		$ExplosionAudio.play()
	
func take_damage(by_who, damage):
#	print("take_damage - ", by_who, " - ", player_id)
	if by_who == player_id or enable_shield:
		return
	if by_who == GameState.get_current_id() or player_id == GameState.get_current_id():
		$TakeDamageAudio.play()
	health -= damage
	health_change()
	if health <= 0:
		explode(by_who)
		get_node("../../Score").increase_score(by_who)
		
func health_change():
	bar_texture = bar_green
	if health < 20:
		bar_texture = bar_red
	elif health < 60:
		bar_texture = bar_yellow
	$HealthBar.texture_progress = bar_texture
	$Tween.interpolate_property($HealthBar,'value', $HealthBar.value, health, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func _on_Timer_timeout():
	can_shoot = true

func _on_Explosion_animation_finished():
#	print("_on_Explosion_animation_finished - ", $Explosion.animation)
	respawn()
	
func set_player(_id, new_player):
	player_id = _id
	is_bot = new_player.is_bot
	$Label.text = new_player.name
	$Body.frame = new_player.tank
	$Turret.frame = new_player.tank
	
func respawn_value():
	pass
	
func respawn():
	$Explosion.stop()
	$Explosion.hide()
	alive = true
	can_shoot = true
	health = max_health
	health_change()
	respawn_value()
	$Body.show()
	$Turret.show()
	enable_shield()
	if GameState.is_host():
		var map = get_node("../..")
		var size = map.get_node("SpawnPoints").get_child_count()
		var random = RandomNumberGenerator.new()
		random.randomize()
		var index = random.randi_range(0, size-1)
		var spawn_pos = map.get_node("SpawnPoints/" + str(index)).position
		position = spawn_pos
		return

func enable_shield():
	$Shield.show()
	$Shield.play("shield")
	$ShieldTimer.start()
	enable_shield = true

func _on_ShieldTimer_timeout():
	$Shield.stop()
	$Shield.hide()
	enable_shield = false
	
func pick_up_buff(_type):
	if _type == Globals.BUFF_ITEMS.damage:
		bullet_damage += Globals.BUFF_VALUES[_type]
	elif _type == Globals.BUFF_ITEMS.health:
		health += Globals.BUFF_VALUES[_type]
		health_change()
	elif _type == Globals.BUFF_ITEMS.firespeed:
		bullet_speed += Globals.BUFF_VALUES[_type]
	elif _type == Globals.BUFF_ITEMS.speed:
		speed += Globals.BUFF_VALUES[_type]
	else:
		return
	
	if player_id == GameState.get_current_id():
		$PickUpAudio.play()
