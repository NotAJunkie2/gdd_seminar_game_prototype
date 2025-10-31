class_name Zone extends Node


enum zoneType {SLOW, FAST, RANGED}

signal zone_ended_signal
signal current_wave
signal current_zone

@onready var spawner_manager: SpawnerManager = $SpawnerManager
@onready var background: ColorRect = get_node("/root/World/BackgroundLayer/Background")

var chest_scene: PackedScene = preload("res://scenes/Chest.tscn")
var random_chest_spawner: Node = null

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
	setup_random_chest_spawner()
	manage_wave()


func setup_random_chest_spawner() -> void:
	# Créer le spawner de coffres aléatoires s'il n'existe pas
	if not random_chest_spawner:
		random_chest_spawner = Node.new()
		random_chest_spawner.name = "RandomChestSpawner"
		random_chest_spawner.set_script(preload("res://scripts/zones/randomChestSpawner.gd"))
		add_child(random_chest_spawner)


func on_zone_complete() -> void:
	waiting_for_chest = true
	spawn_chest()


func spawn_chest() -> void:
	print("=== SPAWNING ZONE COMPLETION CHEST ===")
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("ERROR: Player not found for chest spawn!")
		next_zone()
		return
	
	var chest = chest_scene.instantiate()
	var spawn_position = player.global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
	chest.global_position = spawn_position
	chest.chest_opened.connect(_on_chest_opened)
	print("Chest spawning at position: ", spawn_position, " (Player at: ", player.global_position, ")")
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
	
	# Nettoyer les coffres aléatoires de la zone précédente
	if random_chest_spawner:
		random_chest_spawner.clear_all_chests()
	
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
	
	# Attendre que tous les ennemis soient spawned avant de marquer la wave comme "terminée"
	await get_tree().process_frame
	spawner_manager.isWaveEnded = true
	print("Wave ", CURRENT_WAVE, " spawning complete. Enemies to kill: ", enemies_to_spawn)
	
	# Spawn des coffres aléatoires sur la map (sauf à la dernière vague)
	if CURRENT_WAVE < 5 and random_chest_spawner:
		random_chest_spawner.spawn_random_chests()


func manage_boss() -> void:
	print("Boss zone - Not implemented yet")


func setup_background() -> void:
	if not background:
		return
	
	# Couleurs sombres et mystérieuses type space/dungeon
	var zone_colors = [
		Color(0.08, 0.06, 0.15, 1),   # Zone 1: Violet très sombre
		Color(0.05, 0.08, 0.18, 1),   # Zone 2: Bleu nuit profond
		Color(0.12, 0.05, 0.08, 1),   # Zone 3: Rouge bordeaux
		Color(0.05, 0.12, 0.10, 1),   # Zone 4: Vert forêt noire
		Color(0.15, 0.10, 0.05, 1),   # Zone 5: Brun chocolat
		Color(0.10, 0.06, 0.14, 1),   # Zone 6: Violet améthyste
		Color(0.05, 0.14, 0.12, 1),   # Zone 7: Cyan profond
		Color(0.14, 0.05, 0.12, 1),   # Zone 8: Magenta sombre
		Color(0.12, 0.12, 0.08, 1),   # Zone 9: Olive militaire
		Color(0.08, 0.08, 0.16, 1),   # Zone 10: Indigo marine
		Color(0.18, 0.05, 0.05, 1)    # Zone 11: Rouge sang (boss)
	]
	
	var color_index = min(CURRENT_ZONE - 1, zone_colors.size() - 1)
	var target_color = zone_colors[color_index]
	
	# Transition douce de couleur
	var tween = create_tween()
	tween.tween_property(background, "color", target_color, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
