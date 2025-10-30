class_name StateMachine extends Node


@export var CURRENT_STATE: State
var states: Dictionary = {}


func _ready() -> void:
	for child: State in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")
	await owner.ready
	CURRENT_STATE.enter(null)
	pass

func process_input(event: InputEvent) -> void:
	CURRENT_STATE.process_input(event)
	pass

func process_frame(_delta: float) -> void:
	CURRENT_STATE.process_frame(_delta)
	pass


func process_physics(_delta: float) -> void:
	CURRENT_STATE.process_physics(_delta)
	pass


func on_child_transition(new_state_name: StringName) -> void:
	var new_state: State = states.get(new_state_name)
	if new_state != null:
		CURRENT_STATE.exit()
		new_state.enter(CURRENT_STATE)
		CURRENT_STATE = new_state
	else:
		push_warning("States does not exist: ", new_state_name)
	pass
