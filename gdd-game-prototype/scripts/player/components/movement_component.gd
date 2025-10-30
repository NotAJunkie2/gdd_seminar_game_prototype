class_name MovementComponent extends Node

# Return the desired direction of movement for the character
# in the range [-1, 1], where positive values indicate a desire
# to move to the right and negative values to the left.
func get_movement_direction() -> Vector2:
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if direction.length() > 1:
		direction = direction.normalized()
	return direction
