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

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	hitbox.damaged.connect(on_damaged)
	MAX_HEALTH = HEALTH
	health_changed.emit(HEALTH, MAX_HEALTH)

func take_damage(value: float) -> void:
	HEALTH -= value
	health_changed.emit(HEALTH, MAX_HEALTH)
	juice_damage()
	if HEALTH <= 0:
		set_physics_process(false)
		set_process(false)
		collision_layer = 0
		collision_mask = 0
		if hitbox:
			hitbox.set_deferred("monitoring", false)
			hitbox.set_deferred("monitorable", false)
		
		var exp_drop: ExpDrop = expScene.instantiate()
		exp_drop.EXPERIENCE_POINTS = EXPVALUE
		exp_drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_drop)
		Enemy_died.emit()
		
		juice_death()
		await get_tree().create_timer(0.4).timeout
		queue_free()


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
	create_explosion_effect()
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	modulate = Color(1.5, 0.5, 0.2)
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0, 0.0), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", scale * 1.2, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "rotation", rotation + TAU * 2, 0.4).set_trans(Tween.TRANS_CUBIC)


func create_explosion_effect() -> void:
	var particle_count = 12
	for i in range(particle_count):
		var particle = ColorRect.new()
		particle.size = Vector2(randf_range(3, 8), randf_range(3, 8))
		particle.color = Color(randf_range(0.8, 1.0), randf_range(0.3, 0.6), randf_range(0.1, 0.3))
		particle.position = global_position - particle.size / 2
		get_tree().current_scene.call_deferred("add_child", particle)
		
		var angle = (TAU / particle_count) * i + randf_range(-0.3, 0.3)
		var distance = randf_range(30, 80)
		var end_pos = particle.position + Vector2(cos(angle), sin(angle)) * distance
		
		var particle_tween = get_tree().create_tween()
		particle_tween.set_parallel(true)
		particle_tween.tween_property(particle, "position", end_pos, randf_range(0.3, 0.5)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		particle_tween.tween_property(particle, "modulate:a", 0.0, 0.4).set_delay(0.1)
		particle_tween.tween_property(particle, "scale", Vector2.ZERO, 0.4).set_delay(0.1)
		particle_tween.finished.connect(func(): particle.queue_free())


func multiplyStats(value: float) -> void:
	HEALTH = HEALTH * value
	MAX_HEALTH = HEALTH
	DAMAGE = DAMAGE * value
	SPEED = SPEED * value
	EXPVALUE = EXPVALUE * value


func _on_body_entered(body: Node) -> void:
	if body is Player:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)


func on_damaged(attack: Attack) -> void:
	take_damage(attack.damage)
