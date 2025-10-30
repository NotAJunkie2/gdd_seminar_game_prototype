class_name Player extends CharacterBody2D

# PLAYER
@export var MOVE_SPEED: float = 250
@export var MAX_HEALTH: float = 100
@export var HEALTH: float = 100
# WEAPON STATS
@export var DAMAGE_MULTIPLIER = 1.0
@export var RANGE: float = 1.0
@export var PROJECTILE_COUNT: int = 1
@export var CRITICAL_CHANCE: float = 0.0
@export var CRITICAL_DAMAGE: float = 1.0
@export var ATTACK_SPEED: float = 1.0
# EXP PICKUP RANGE
@export var PICKUP_RANGE: float = 1.0

@onready var MOVEMENT_FSM: StateMachine = $movement_fsm
@onready var MOVEMENT_CMP: MovementComponent = $movement_component
@onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

func _init() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	MOVEMENT_FSM.process_input(event)

func _physics_process(delta: float) -> void:
	MOVEMENT_FSM.process_physics(delta)
	move_and_slide()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	MOVEMENT_FSM.process_frame(delta)
