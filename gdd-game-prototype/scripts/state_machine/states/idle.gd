class_name Player_Idle extends PlayerState

func enter(_state: State) -> void:
	super(_state)
	pass

func exit() -> void:
	pass

func process_frame(delta: float) -> void:
	super(delta)
	# Transition to other states
	var input_dir: Vector2 = MOVEMENT_COMPONENT.get_movement_direction()
	if input_dir.length() > 0.0:
		transition.emit("Move")

func process_input(_event: InputEvent) -> void:
	super(_event)
	pass
