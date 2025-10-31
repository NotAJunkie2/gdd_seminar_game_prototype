extends ProgressBar


var enemy: Enemy
var is_reparented: bool = false


func _ready() -> void:
	call_deferred("_setup_health_bar")


func _process(_delta: float) -> void:
	if enemy and is_reparented:
		global_position = enemy.global_position + Vector2(-30, -50)


func _setup_health_bar() -> void:
	enemy = get_parent() as Enemy
	if enemy:
		enemy.health_changed.connect(_on_health_changed)
		
		var original_global_pos = global_position
		var scene_root = get_tree().current_scene
		get_parent().remove_child(self)
		scene_root.add_child(self)
		global_position = original_global_pos
		is_reparented = true
		
		z_index = 10
		size = Vector2(60, 6)
		min_value = 0
		max_value = 100
		value = 100
		show_percentage = false
		
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		style_bg.set_corner_radius_all(3)
		style_bg.border_width_left = 1
		style_bg.border_width_top = 1
		style_bg.border_width_right = 1
		style_bg.border_width_bottom = 1
		style_bg.border_color = Color(0.0, 0.0, 0.0, 0.6)
		add_theme_stylebox_override("background", style_bg)
		
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(0.9, 0.2, 0.2, 1.0)
		style_fill.set_corner_radius_all(3)
		add_theme_stylebox_override("fill", style_fill)
	else:
		print("ProgressBar: Enemy not found!")


func _on_health_changed(current_health: float, max_health: float) -> void:
	if max_health > 0:
		var health_percent = (current_health / max_health) * 100
		value = health_percent
		
		var style_fill = StyleBoxFlat.new()
		style_fill.set_corner_radius_all(3)
		
		if health_percent > 60:
			style_fill.bg_color = Color(0.3, 0.9, 0.3, 1.0)
		elif health_percent > 30:
			style_fill.bg_color = Color(0.9, 0.7, 0.2, 1.0)
		else:
			style_fill.bg_color = Color(0.9, 0.2, 0.2, 1.0)
		
		add_theme_stylebox_override("fill", style_fill)
		
		if current_health <= 0:
			visible = false
