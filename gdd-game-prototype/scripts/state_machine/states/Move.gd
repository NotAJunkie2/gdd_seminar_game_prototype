class_name Player_Move extends PlayerState
@onready var gpu_particles_2d: GPUParticles2D = $"../../GPUParticles2D"

func enter(_previous_state: State) -> void:
	gpu_particles_2d.emitting = true
	super(_previous_state)

func exit() -> void:
	gpu_particles_2d.emitting = false
	pass

func process_frame(delta: float) -> void:
	super(delta)
	
	if PLAYER.velocity.length() < 0.01:
		transition.emit("Idle")
	pass

func process_physics(delta: float) -> void:
	super(delta)
	pass

func process_input(event: InputEvent) -> void:
	super(event)
	pass
