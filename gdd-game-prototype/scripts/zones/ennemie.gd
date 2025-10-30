class_name Enemy extends CharacterBody2D

signal Enemy_died
@export var player: Player

var expScene: PackedScene = preload("res://scenes/Exp.tscn")

@export var HEALTH: float
@export var SPEED: float
@export var DAMAGE: float
@export var EXPVALUE: float

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	hitbox.damaged.connect(on_damaged)

func take_damage(value: float) -> void:
	HEALTH -= value
	if HEALTH <= 0:
		var exp_drop: ExpDrop = expScene.instantiate()
		exp_drop.EXPERIENCE_POINTS = EXPVALUE
		exp_drop.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", exp_drop)
		Enemy_died.emit()
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)


func on_damaged(attack: Attack) -> void:
	print("ATTACKED")
	take_damage(attack.damage)
