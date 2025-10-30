class_name Zone extends Node


enum zoneType {SLOW, FAST, RANGED}

signal zone_ended_signal

signal current_wave
signal current_zone

@onready var spawner_manager: SpawnerManager = $SpawnerManager

var CURRENT_ZONE: int = 1
var CURRENT_WAVE: int = 1
var current_zone_type: zoneType


func _ready() -> void:
	zone_ended_signal.connect(next_zone)
	spawner_manager.wave_ended.connect(next_wave)
	current_zone_type = get_random_zone_type()
	manage_wave()


func next_zone() -> void:
	CURRENT_ZONE += 1
	current_zone.emit(CURRENT_ZONE)
	CURRENT_WAVE = 1
	current_wave.emit(CURRENT_WAVE)
	if CURRENT_ZONE != 12:
		current_zone_type = get_random_zone_type()
		manage_wave()
	else:
		manage_boss()
	pass


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
