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
	hitbox.body_entered.connect(_on_body_entered)
	MAX_HEALTH = HEALTH
	health_changed.emit(HEALTH, MAX_HEALTH)

func take_damage(value: float) -> void:
	HEALTH -= value
	health_changed.emit(HEALTH, MAX_HEALTH)
	if HEALTH <= 0:
		var exp_drop: ExpDrop = expScene.instantiate()
		exp_drop.EXPERIENCE_POINTS = EXPVALUE
		exp_drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_drop)
		Enemy_died.emit()
		queue_free()


func multiplyStats(value: float) -> void:
	HEALTH = HEALTH * value
	MAX_HEALTH = HEALTH
	DAMAGE = DAMAGE * value
	SPEED = SPEED * value
	EXPVALUE = EXPVALUE * value


func _on_body_entered(body: Node) -> void:
	print("Enemy collision with: ", body.name, " (is Player: ", body is Player, ")")
	if body is Player:
		print("Dealing ", DAMAGE, " damage to player!")
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)


func on_damaged(attack: Attack) -> void:
	take_damage(attack.damage)
