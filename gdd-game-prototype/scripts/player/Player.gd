class_name Player extends CharacterBody2D

# PLAYER
@export var MOVE_SPEED: float = 250
@export var MAX_HEALTH: int = 100
@export var HEALTH: int = 100
@export var SHIELD: int = 25
# WEAPON STATS
@export var DAMAGE_MULTIPLIER = 1.0
@export var RANGE: float = 1.0
@export var PROJECTILE_COUNT: int = 1
@export var CRITICAL_CHANCE: float = 0.0
@export var CRITICAL_DAMAGE: float = 1.0
@export var ATTACK_SPEED: float = 1.0
# EXP PICKUP RANGE
@export var PICKUP_RANGE: float = 1.0
@export var LEVEL: int = 1
@export var CURRENT_XP: float = 0.0
@export var XP_TO_NEXT_LEVEL: float = 100.0

@onready var MOVEMENT_FSM: StateMachine = $movement_fsm
@onready var MOVEMENT_CMP: MovementComponent = $movement_component
@onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

@export var aim_position : Vector2 = Vector2(1, 0)

func _init() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	MOVEMENT_FSM.process_input(event)
	
	if event is InputEventMouseMotion:
		var half_viewport = get_viewport_rect().size / 2.0
		aim_position = (event.position - half_viewport)

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	MOVEMENT_FSM.process_physics(delta)
	move_and_slide()

func _process(delta: float) -> void:
	MOVEMENT_FSM.process_frame(delta)

func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pickup") and area is Pickup:
		area.collect()
		pass
	pass # Replace with function body.


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pickup"):
		(area as Pickup).FOLLOW_PLAYER = true
		pass
	pass # Replace with function body.
