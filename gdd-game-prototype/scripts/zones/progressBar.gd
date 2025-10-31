extends ProgressBar


var enemy: Enemy


func _ready() -> void:
	call_deferred("_setup_health_bar")


func _setup_health_bar() -> void:
	enemy = get_parent() as Enemy
	if enemy:
		enemy.health_changed.connect(_on_health_changed)
		
		z_index = 10
		position = Vector2(-40, -50)
		size = Vector2(80, 10)
		min_value = 0
		max_value = 100
		value = 100
		show_percentage = false
		modulate = Color(1, 1, 1, 0.7)
		
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		style_bg.set_corner_radius_all(3)
		add_theme_stylebox_override("background", style_bg)
		
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(0.8, 0.1, 0.1, 1.0)
		style_fill.set_corner_radius_all(3)
		add_theme_stylebox_override("fill", style_fill)
	else:
		print("ProgressBar: Enemy not found!")


func _on_health_changed(current_health: float, max_health: float) -> void:
	if max_health > 0:
		value = (current_health / max_health) * 100
		if current_health <= 0:
			visible = false
