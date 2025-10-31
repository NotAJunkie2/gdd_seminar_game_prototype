extends CanvasLayer

@onready var zone_panel: PanelContainer = $Control/TopRight/ZonePanel
@onready var zone_label: Label = $Control/TopRight/ZonePanel/VBoxContainer/ZoneValue
@onready var wave_label: Label = $Control/TopRight/ZonePanel/VBoxContainer/WaveValue
@onready var enemies_panel: PanelContainer = $Control/TopRight/EnemiesPanel
@onready var enemies_label: Label = $Control/TopRight/EnemiesPanel/VBoxContainer/EnemiesValue


var zone_node: Zone


func _ready() -> void:
	layer = 100
	setup_hud_style()
	call_deferred("_setup_connections")


func setup_hud_style() -> void:
	if zone_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
		style.set_corner_radius_all(8)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.5, 0.8, 0.8)
		zone_panel.add_theme_stylebox_override("panel", style)
	
	if enemies_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.1, 0.1, 0.85)
		style.set_corner_radius_all(8)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.8, 0.3, 0.3, 0.8)
		enemies_panel.add_theme_stylebox_override("panel", style)
	
	setup_label_style(zone_label)
	setup_label_style(wave_label)
	setup_label_style(enemies_label)


func setup_label_style(label: Label) -> void:
	if label:
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_font_size_override("font_size", 24)


func _setup_connections() -> void:
	zone_node = get_tree().get_first_node_in_group("Zone")
	if not zone_node:
		zone_node = get_node_or_null("/root/World/Zone")
	
	print("HUD: zone_node found = ", zone_node != null)
	
	if zone_node:
		zone_node.current_zone.connect(_on_zone_changed)
		zone_node.current_wave.connect(_on_wave_changed)
		if zone_node.spawner_manager:
			zone_node.spawner_manager.nb_of_enemies.connect(_on_enemies_count_changed)
			_on_enemies_count_changed(zone_node.spawner_manager.EnemyCounter)
		
		_on_zone_changed(zone_node.CURRENT_ZONE)
		_on_wave_changed(zone_node.CURRENT_WAVE)
	else:
		print("HUD: Zone node not found!")
		zone_label.text = "ERROR"
		wave_label.text = "ERROR"
		enemies_label.text = "ERROR"


func _on_zone_changed(zone_number: int) -> void:
	if zone_label:
		zone_label.text = str(zone_number)


func _on_wave_changed(wave_number: int) -> void:
	if wave_label:
		wave_label.text = str(wave_number) + " / 5"


func _on_enemies_count_changed(count: int) -> void:
	if enemies_label:
		enemies_label.text = str(count)
		
		var color = Color.WHITE
		if count > 20:
			color = Color(1.0, 0.3, 0.3)
		elif count > 10:
			color = Color(1.0, 0.7, 0.3)
		enemies_label.add_theme_color_override("font_color", color)
