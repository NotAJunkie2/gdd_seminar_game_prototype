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
	var tween = create_tween()
	tween.set_parallel(true)
	
	modulate = Color(2.0, 0.3, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	var original_scale = scale
	tween.tween_property(self, "scale", original_scale * 1.3, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * 0.9, 0.08).set_delay(0.08).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", original_scale, 0.08).set_delay(0.16).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	for i in range(3):
		var shake_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		var original_pos = position
		tween.tween_property(self, "position", original_pos + shake_offset, 0.03).set_delay(i * 0.03)
		tween.tween_property(self, "position", original_pos, 0.03).set_delay(i * 0.03 + 0.03)
	
	tween.tween_property(self, "rotation", rotation + randf_range(-0.3, 0.3), 0.1)
	tween.tween_property(self, "rotation", rotation, 0.1).set_delay(0.1)


func juice_death() -> void:

	var tween = create_tween()
	tween.set_parallel(true)
	
	modulate = Color(1.5, 0.5, 0.2)
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0, 0.0), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", scale * 1.2, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "rotation", rotation + TAU * 2, 0.4).set_trans(Tween.TRANS_CUBIC)
