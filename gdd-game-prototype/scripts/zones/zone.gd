class_name Zone extends Node


enum zoneType {SLOW, FAST, RANGED}

signal zone_ended_signal
signal current_wave
signal current_zone

@onready var spawner_manager: SpawnerManager = $SpawnerManager
@onready var background: Sprite2D = get_node("/root/World/Background")

var chest_scene: PackedScene = preload("res://scenes/Chest.tscn")

var CURRENT_ZONE: int = 1
var CURRENT_WAVE: int = 1
var current_zone_type: zoneType
var waiting_for_chest: bool = false


func _ready() -> void:
	zone_ended_signal.connect(on_zone_complete)
	spawner_manager.wave_ended.connect(next_wave)
	spawner_manager.set_zone_number(CURRENT_ZONE)
	current_zone_type = get_random_zone_type()
	setup_background()
	manage_wave()


func on_zone_complete() -> void:
	waiting_for_chest = true
	spawn_chest()


func spawn_chest() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		next_zone()
		return
	
	var chest = chest_scene.instantiate()
	chest.global_position = player.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	chest.chest_opened.connect(_on_chest_opened)
	get_tree().current_scene.call_deferred("add_child", chest)


func _on_chest_opened() -> void:
	waiting_for_chest = false
	next_zone()


func next_zone() -> void:
	CURRENT_ZONE += 1
	current_zone.emit(CURRENT_ZONE)
	spawner_manager.set_zone_number(CURRENT_ZONE)
	CURRENT_WAVE = 1
	current_wave.emit(CURRENT_WAVE)
	
	setup_background()
	
	if CURRENT_ZONE != 12:
		current_zone_type = get_random_zone_type()
		manage_wave()
	else:
		manage_boss()


func next_wave() -> void:
	CURRENT_WAVE += 1
	current_wave.emit(CURRENT_WAVE)
	if CURRENT_WAVE > 5:
		zone_ended_signal.emit()
	else:
		manage_wave()


func get_random_zone_type() -> zoneType:
	var random_type = randi() % 3
	match random_type:
		0:
			return zoneType.SLOW
		1:
			return zoneType.FAST
		2:
			return zoneType.RANGED
		_:
			return zoneType.SLOW


func manage_wave() -> void:
	spawner_manager.isWaveEnded = false
	var enemies_to_spawn = CURRENT_WAVE * 10
	for i in range(enemies_to_spawn):
		spawner_manager.spawn_Enemy(current_zone_type)
	spawner_manager.isWaveEnded = true


func manage_boss() -> void:
	print("Boss zone - Not implemented yet")


func setup_background() -> void:
	if not background:
		return
	
	var colors = [
		Color(0.2, 0.15, 0.3),
		Color(0.15, 0.2, 0.35),
		Color(0.25, 0.15, 0.2),
		Color(0.15, 0.25, 0.2),
		Color(0.3, 0.2, 0.15),
		Color(0.2, 0.2, 0.3),
		Color(0.15, 0.3, 0.25),
		Color(0.3, 0.15, 0.25)
	]
	
	var color_index = (CURRENT_ZONE - 1) % colors.size()
	var target_color = colors[color_index]
	
	var tween = create_tween()
	tween.tween_property(background, "modulate", target_color, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
