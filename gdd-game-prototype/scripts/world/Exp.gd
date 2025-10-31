class_name ExpDrop extends Pickup

@export var EXPERIENCE_POINTS: float

func collect() -> void:
	PLAYER.addXP(EXPERIENCE_POINTS)
	queue_free()
