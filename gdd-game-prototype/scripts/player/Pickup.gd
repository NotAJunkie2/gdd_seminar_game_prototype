class_name Pickup extends Area2D

@export var FOLLOW_PLAYER: bool = false
var PLAYER: Player
var FOLLOW_SPEED: float = 200

func _ready() -> void:
	PLAYER = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if not FOLLOW_PLAYER:
		return

	position = position.move_toward(PLAYER.position, FOLLOW_SPEED * delta)

func collect() -> void:
	pass
