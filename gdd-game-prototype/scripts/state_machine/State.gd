class_name State extends Node

signal transition(new_state_name: StringName)


func enter(_state: State) -> void:
	pass


func exit() -> void:
	pass


func process_input(_event: InputEvent) -> void:
	pass


func process_frame(_delta: float) -> void:
	pass


func process_physics(_delta: float) -> void:
	pass
