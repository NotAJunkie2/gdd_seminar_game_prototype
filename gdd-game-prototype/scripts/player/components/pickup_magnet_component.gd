extends Area2D

@onready var player: Player = get_owner()
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var base_radius: float = 50.0

func _ready() -> void:
	# Connect to player's stat_changed signal
	player.stat_changed.connect(_on_player_stat_changed)
	
	# Initialize with current pickup range
	_update_magnet_radius()

func _on_player_stat_changed(stat_name: String, old_value: Variant, new_value: Variant) -> void:
	if stat_name == "PICKUP_RANGE":
		print("Pickup range changed from ", old_value, " to ", new_value)
		_update_magnet_radius()

func _update_magnet_radius() -> void:
	# Scale the magnet radius based on PICKUP_RANGE multiplier
	var new_radius = base_radius * player.PICKUP_RANGE
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		var circle_shape = collision_shape.shape as CircleShape2D
		circle_shape.radius = new_radius
		print("Magnet radius updated to: ", new_radius)
