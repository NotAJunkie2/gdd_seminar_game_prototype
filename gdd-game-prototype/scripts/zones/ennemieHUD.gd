extends CanvasLayer

@onready var zone_label: RichTextLabel = $HBoxContainer/ZoneLabel
@onready var wave_label: RichTextLabel = $HBoxContainer/WaveLabel
@onready var ennemies_counter_label: RichTextLabel = $HBoxContainer/EnnemiesCounterLabel


var zone_node: Zone


func _ready() -> void:
	layer = 100
	setup_label_style(zone_label)
	setup_label_style(ennemies_counter_label)
	setup_label_style(wave_label)
	
	call_deferred("_setup_connections")


func setup_label_style(label: RichTextLabel) -> void:
	if label:
		label.bbcode_enabled = true
		label.add_theme_color_override("default_color", Color.WHITE)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_font_size_override("normal_font_size", 20)


func _setup_connections() -> void:
	zone_node = get_tree().get_first_node_in_group("Zone")
	if not zone_node:
		zone_node = get_node_or_null("/root/World/Zone")
	
	print("HUD: zone_node found = ", zone_node != null)
	
	if zone_node:
		zone_node.current_zone.connect(_on_zone_changed)
		zone_node.current_wave.connect(_on_wave_changed)
		if zone_node.spawner_manager:
			zone_node.spawner_manager.nb_of_ennemies.connect(_on_enemies_count_changed)
			_on_enemies_count_changed(zone_node.spawner_manager.ennemieCounter)
		
		_on_zone_changed(zone_node.CURRENT_ZONE)
		_on_wave_changed(zone_node.CURRENT_WAVE)
	else:
		print("HUD: Zone node not found!")
		zone_label.text = "Zone: ERROR"
		wave_label.text = "Wave: ERROR"
		ennemies_counter_label.text = "Enemies: ERROR"


func _on_zone_changed(zone_number: int) -> void:
	if zone_label:
		zone_label.text = "Zone: " + str(zone_number)
		print("HUD: Zone changed to ", zone_number)


func _on_wave_changed(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "Wave: " + str(wave_number)
		print("HUD: Wave changed to ", wave_number)


func _on_enemies_count_changed(count: int) -> void:
	if ennemies_counter_label:
		ennemies_counter_label.text = "Enemies: " + str(count)
		print("HUD: Enemy count changed to ", count)
