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
	for i in range(8):
		var angle = i * PI / 4
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
	var spawn_pos = spawn_positions[randi() % spawn_positions.size()]
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
