class_name SpawnerManager extends Node2D


signal wave_ended
signal nb_of_enemies

var EnemyCounter: int = 0
var isWaveEnded: bool = false

var defaultEnemy = preload("res://scenes/ennemies/default_enemy.tscn")
var fastEnemy = preload("res://scenes/ennemies/fast_enemy.tscn")
var slowEnemy = preload("res://scenes/ennemies/slow_enemy.tscn")

var spawn_positions: Array[Vector2] = []
@export var spawn_radius: float = 500.0


func _ready() -> void:
	setup_spawn_positions()


func setup_spawn_positions() -> void:
	for i in range(16):
		var angle = i * PI / 8
		var pos = Vector2(cos(angle), sin(angle)) * spawn_radius
		spawn_positions.append(pos)


var current_zone_number: int = 1

func set_zone_number(zone_number: int) -> void:
	current_zone_number = zone_number

func spawn_Enemy(current_zone_type) -> void:
	var Enemy_scene: PackedScene
	var random_value = randf()
	
	match current_zone_type:
		0:
			if random_value < 0.6:
				Enemy_scene = slowEnemy
			elif random_value < 0.85:
				Enemy_scene = defaultEnemy
			else:
				Enemy_scene = fastEnemy
		1:
			if random_value < 0.6:
				Enemy_scene = fastEnemy
			elif random_value < 0.85:
				Enemy_scene = defaultEnemy
			else:
				Enemy_scene = slowEnemy
		_:
			if random_value < 0.6:
				Enemy_scene = defaultEnemy
			elif random_value < 0.85:
				Enemy_scene = fastEnemy
			else:
				Enemy_scene = slowEnemy
	
	var enemy: Enemy = Enemy_scene.instantiate()
	
	var player = get_tree().get_first_node_in_group("Player")
	var spawn_pos: Vector2
	
	if player:
		var screen_size = get_viewport().get_visible_rect().size
		var camera_pos = player.global_position
		var min_distance = max(screen_size.x, screen_size.y) * 0.6
		
		var valid_position_found = false
		var attempts = 0
		var max_attempts = 10
		
		while not valid_position_found and attempts < max_attempts:
			var angle = randf() * TAU
			var distance = randf_range(min_distance, min_distance + 200 + (attempts * 50))
			spawn_pos = Vector2(cos(angle), sin(angle)) * distance
			var test_position = camera_pos + spawn_pos
			
			if is_position_free(test_position, 50.0):
				valid_position_found = true
				enemy.global_position = test_position
			
			attempts += 1
		
		if not valid_position_found:
			var angle = randf() * TAU
			var distance = min_distance + 300
			spawn_pos = Vector2(cos(angle), sin(angle)) * distance
			enemy.global_position = camera_pos + spawn_pos
	else:
		spawn_pos = spawn_positions[randi() % spawn_positions.size()]
		enemy.global_position = global_position + spawn_pos
	
	var multiplier = 1.0 + (current_zone_number - 1) * 0.2
	enemy.multiplyStats(multiplier)
	
	enemy.Enemy_died.connect(EnemyCount)
	get_tree().current_scene.call_deferred("add_child", enemy)
	
	EnemyCounter += 1
	nb_of_enemies.emit(EnemyCounter)


func EnemyCount() -> void:
	EnemyCounter -= 1
	if EnemyCounter < 0:
		EnemyCounter = 0
	nb_of_enemies.emit(EnemyCounter)
	if isWaveEnded and EnemyCounter <= 0:
		wave_ended.emit()


func possibilityToEmit() -> void:
	isWaveEnded = true


func is_position_free(pos: Vector2, radius: float) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 2
	
	var circle_query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	circle_query.shape = shape
	circle_query.transform = Transform2D(0, pos)
	circle_query.collision_mask = 2
	
	var result = space_state.intersect_shape(circle_query, 1)
	return result.size() == 0
