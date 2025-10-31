class_name UpgradeData extends Resource

@export var upgrade_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D = null
@export var stat_type: String = "" # The stat to modify
@export var value_change: float = 0.0 # Amount to change the stat
@export var is_percentage: bool = false # If true, multiply instead of add

func apply_to_player(player: Player) -> void:
	# Use the player's centralized stat modification function
	player.modify_stat(stat_type, value_change, is_percentage)

func get_display_text() -> String:
	var value_text = ""
	if is_percentage:
		value_text = "+" + str(int(value_change * 100)) + "%"
	else:
		if value_change > 0:
			value_text = "+" + str(value_change)
		else:
			value_text = str(value_change)

	return upgrade_name + "\n" + description + "\n" + value_text
