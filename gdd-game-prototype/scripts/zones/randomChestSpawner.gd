class_name RandomChestSpawner extends Node

@export var chest_scene: PackedScene = preload("res://scenes/Chest.tscn")
@export var min_chests_per_wave: int = 1
@export var max_chests_per_wave: int = 3
@export var spawn_radius_min: float = 300.0
@export var spawn_radius_max: float = 800.0

var spawned_chests: Array[Chest] = []


func spawn_random_chests() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
	
	# Nombre aléatoire de coffres
	var chest_count = randi_range(min_chests_per_wave, max_chests_per_wave)
	
	for i in range(chest_count):
		var chest_position = get_random_position_around_player(player.global_position)
		spawn_chest_at_position(chest_position)


func get_random_position_around_player(player_pos: Vector2) -> Vector2:
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return player_pos + offset


func spawn_chest_at_position(position: Vector2) -> void:
	# Vérifier si la position est libre
	var space_state = get_tree().root.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = 2  # Masque des ennemis
	
	var result = space_state.intersect_point(query, 1)
	
	# Si trop d'objets à cette position, essayer une autre
	if result.size() > 0:
		position += Vector2(randf_range(-100, 100), randf_range(-100, 100))
	
	var chest = chest_scene.instantiate()
	chest.global_position = position
	chest.chest_opened.connect(_on_random_chest_opened.bind(chest))
	get_tree().current_scene.call_deferred("add_child", chest)
	spawned_chests.append(chest)


func _on_random_chest_opened(chest: Chest) -> void:
	spawned_chests.erase(chest)


func clear_all_chests() -> void:
	for chest in spawned_chests:
		if is_instance_valid(chest):
			chest.queue_free()
	spawned_chests.clear()
