class_name Enemy extends CharacterBody2D

signal Enemy_died
@export var player: Player

var expScene: PackedScene = preload("res://scenes/Exp.tscn")

@export var HEALTH: float
@export var SPEED: float
@export var DAMAGE: float
@export var EXPVALUE: float


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func take_damage(value: float) -> void:
	HEALTH -= value
	if HEALTH <= 0:
		var exp_drop: ExpDrop = expScene.instantiate()
		exp_drop.EXPERIENCE_POINTS = EXPVALUE
		exp_drop.global_position = global_position
		get_tree().current_scene.add_child(exp_drop)
		Enemy_died.emit()
		self.queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
