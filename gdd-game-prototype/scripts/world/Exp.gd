class_name ExpDrop extends Pickup

@export var EXPERIENCE_POINTS: float

func collect() -> void:
	PLAYER.CURRENT_XP += EXPERIENCE_POINTS
	print("Player's XP: ", PLAYER.CURRENT_XP)
	queue_free()
