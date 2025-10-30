class_name Player_Move extends PlayerState

func enter(_previous_state: State) -> void:
	super(_previous_state)

func exit() -> void:
	pass

func process_frame(delta: float) -> void:
	super(delta)
	pass

func process_physics(delta: float) -> void:
	super(delta)
	if PLAYER.velocity.length() < 0.01:
		transition.emit("Idle")
	pass

func process_input(event: InputEvent) -> void:
	super(event)
	pass
