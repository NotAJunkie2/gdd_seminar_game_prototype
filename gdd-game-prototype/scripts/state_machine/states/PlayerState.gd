class_name PlayerState extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var MOVEMENT_COMPONENT: MovementComponent

var MOVEMENT_INPUT: Vector2 = Vector2.ZERO

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATION_PLAYER
	MOVEMENT_COMPONENT = PLAYER.MOVEMENT_CMP

func enter(_previous_state: State) -> void:
	pass

func process_frame(_delta: float) -> void:
	MOVEMENT_INPUT = get_movement_input()

func process_physics(_delta: float) -> void:
	# Compute horizontal input
	apply_movement(MOVEMENT_INPUT)

# Converts 2D input vector to 3D world direction relative to player facing
func get_movement_input() -> Vector2:
	var move_input: Vector2 = MOVEMENT_COMPONENT.get_movement_direction()
	if move_input.length() < 0.001:
		return Vector2.ZERO

	return move_input

# Updates desired velocity based on player speed and input
func apply_movement(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		PLAYER.velocity.x = 0.0
		PLAYER.velocity.y = 0.0
	else:
		var target_velocity: Vector2 = direction * PLAYER.MOVE_SPEED
		print("APPLY MOVEMENT: ", target_velocity)
		PLAYER.velocity.x = target_velocity.x
		PLAYER.velocity.y = target_velocity.y
