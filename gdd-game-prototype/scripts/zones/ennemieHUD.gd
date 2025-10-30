extends Node


@onready var zone_label: RichTextLabel = $HBoxContainer/ZoneLabel
@onready var ennemies_counter_label: RichTextLabel = $HBoxContainer/EnnemiesCounterLabel
@onready var wave_label: RichTextLabel = $HBoxContainer/WaveLabel

var zone_node: Zone


func _ready() -> void:
	zone_node = get_tree().get_first_node_in_group("zone")
	if not zone_node:
		zone_node = get_node_or_null("/root/World/Zone")
	
	if zone_node:
		zone_node.current_zone.connect(_on_zone_changed)
		zone_node.current_wave.connect(_on_wave_changed)
		zone_node.spawner_manager.nb_of_ennemies.connect(_on_enemies_count_changed)
		
		_on_zone_changed(zone_node.CURRENT_ZONE)
		_on_wave_changed(zone_node.CURRENT_WAVE)
		_on_enemies_count_changed(0)


func _on_zone_changed(zone_number: int) -> void:
	zone_label.text = "Zone: " + str(zone_number)


func _on_wave_changed(wave_number: int) -> void:
	wave_label.text = "Wave: " + str(wave_number)


func _on_enemies_count_changed(count: int) -> void:
	ennemies_counter_label.text = "Enemies: " + str(count)
