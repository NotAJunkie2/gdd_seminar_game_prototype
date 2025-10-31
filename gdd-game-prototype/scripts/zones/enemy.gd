class_name Enemy extends CharacterBody2D

signal Enemy_died
signal health_changed(current_health: float, max_health: float)

@export var player: Player

var expScene: PackedScene = preload("res://scenes/Exp.tscn")

@export var HEALTH: float
@export var MAX_HEALTH: float
@export var SPEED: float
@export var DAMAGE: float
@export var EXPVALUE: float
@export var DAMAGE_COOLDOWN: float = 1.0  # Dégâts toutes les 1 seconde

@onready var hitbox: Area2D = $Hitbox

var bodies_in_contact: Array[Node] = []
var damage_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	if hitbox:
		hitbox.damaged.connect(on_damaged)
		hitbox.body_entered.connect(_on_body_entered)
		hitbox.body_exited.connect(_on_body_exited)
		print("Enemy hitbox connected for ", name)
	else:
		print("ERROR: No Hitbox found for ", name)
	
	MAX_HEALTH = HEALTH
	health_changed.emit(HEALTH, MAX_HEALTH)

func take_damage(value: float) -> void:
	HEALTH -= value
	health_changed.emit(HEALTH, MAX_HEALTH)
	
	# Effet visuel de dégâts
	juice_damage()
	
	if HEALTH <= 0:
		juice_death()
		var exp_drop: ExpDrop = expScene.instantiate()
		exp_drop.EXPERIENCE_POINTS = EXPVALUE
		exp_drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_drop)
		Enemy_died.emit()
		await get_tree().create_timer(0.4).timeout
		queue_free()


func multiplyStats(value: float) -> void:
	HEALTH = HEALTH * value
	MAX_HEALTH = HEALTH
	DAMAGE = DAMAGE * value
	SPEED = SPEED * value
	EXPVALUE = EXPVALUE * value


func _physics_process(delta: float) -> void:
	# Infliger des dégâts continus aux corps en contact
	if bodies_in_contact.size() > 0:
		damage_timer -= delta
		if damage_timer <= 0:
			damage_timer = DAMAGE_COOLDOWN
			for body in bodies_in_contact:
				if is_instance_valid(body) and body is Player:
					if body.has_method("take_damage"):
						body.take_damage(DAMAGE)
						print("Dealing ", DAMAGE, " damage to player (continuous)!")


func _on_body_entered(body: Node) -> void:
	print("Enemy collision with: ", body.name, " (is Player: ", body is Player, ")")
	if body is Player:
		bodies_in_contact.append(body)
		# Infliger des dégâts immédiatement
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			print("Dealing ", DAMAGE, " damage to player (initial hit)!")
		# Réinitialiser le timer
		damage_timer = DAMAGE_COOLDOWN


func _on_body_exited(body: Node) -> void:
	if body in bodies_in_contact:
		bodies_in_contact.erase(body)
		print("Player left enemy contact")


func on_damaged(attack: Attack) -> void:
	take_damage(attack.damage)


func juice_damage() -> void:
	# Flash rouge et shake
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	# Flash rouge
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(2.0, 0.3, 0.3), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_ELASTIC)
	
	tween.chain().set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)


func juice_death() -> void:
	# Animation de mort
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	# Désactiver les collisions
	collision_layer = 0
	collision_mask = 0
	if hitbox:
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0
	
	# Animation d'explosion
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "rotation", TAU, 0.4)
	
	# Particules
	create_explosion_effect()


func create_explosion_effect() -> void:
	var particle_count = 8
	for i in range(particle_count):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(1.0, 0.5, 0.2)
		particle.position = global_position
		get_tree().current_scene.add_child(particle)
		
		var angle = (TAU / particle_count) * i
		var direction = Vector2(cos(angle), sin(angle))
		var distance = randf_range(30, 60)
		
		var tween = create_tween()
		tween.tween_property(particle, "position", global_position + direction * distance, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.4)
		tween.tween_callback(particle.queue_free)
