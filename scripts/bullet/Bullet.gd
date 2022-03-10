extends Area2D

var speed
var damage
var life_time
var by_who
var velocity = Vector2()

func set_config(player_id, _speed, _damage, _life_time):
	by_who = player_id
	speed = _speed
	damage = _damage
	life_time = _life_time

func start(_position, _direction, _type):
	$Sprite.frame = _type
	position = _position
	rotation = _direction.angle()
	$Timer.wait_time = life_time
	$Timer.start()
	velocity = _direction * speed
	
func _process(delta):
	position += velocity * delta

func explode():
	velocity = Vector2()
	$Sprite.hide()
	$Explosion.show()
	$Explosion.play("fire")

func _on_Timer_timeout():
	explode()

func _on_Bullet_body_entered(body):
	explode()
	if body.has_method('take_damage'):
		body.take_damage(by_who, damage)

func _on_Explosion_animation_finished():
	queue_free()
