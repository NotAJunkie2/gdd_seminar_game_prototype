class_name SpawnerManager extends Node2D


signal wave_ended
signal nb_of_ennemies

var ennemieCounter: int = 0
var isWaveEnded: bool = false

var defaultEnnemie = preload("res://scenes/ennemies/default_ennemie.tscn")
var fastEnnemie = preload("res://scenes/ennemies/fast_ennemie.tscn")
var slowEnnemie = preload("res://scenes/ennemies/slow_ennemie.tscn")

var spawn_positions: Array[Vector2] = []
@export var spawn_radius: float = 500.0


func _ready() -> void:
	setup_spawn_positions()


func setup_spawn_positions() -> void:
	for i in range(8):
		var angle = i * PI / 4
		var pos = Vector2(cos(angle), sin(angle)) * spawn_radius
		spawn_positions.append(pos)


func spawn_ennemie(current_zone_type) -> void:
	var ennemie_scene: PackedScene
	var random_value = randf()
	
	match current_zone_type:
		0:
			if random_value < 0.6:
				ennemie_scene = slowEnnemie
			elif random_value < 0.85:
				ennemie_scene = defaultEnnemie
			else:
				ennemie_scene = fastEnnemie
		1:
			if random_value < 0.6:
				ennemie_scene = fastEnnemie
			elif random_value < 0.85:
				ennemie_scene = defaultEnnemie
			else:
				ennemie_scene = slowEnnemie
		_:
			if random_value < 0.6:
				ennemie_scene = defaultEnnemie
			elif random_value < 0.85:
				ennemie_scene = fastEnnemie
			else:
				ennemie_scene = slowEnnemie
	
	var ennemie: Ennemie = ennemie_scene.instantiate()
	var spawn_pos = spawn_positions[randi() % spawn_positions.size()]
	ennemie.global_position = global_position + spawn_pos
	ennemie.ennemie_died.connect(ennemieCount)
	get_tree().current_scene.call_deferred("add_child", ennemie)
	
	ennemieCounter += 1
	nb_of_ennemies.emit(ennemieCounter)


func ennemieCount() -> void:
	ennemieCounter -= 1
	nb_of_ennemies.emit(ennemieCounter)
	if isWaveEnded and ennemieCounter <= 0:
		wave_ended.emit()


func possibilityToEmit() -> void:
	isWaveEnded = true
