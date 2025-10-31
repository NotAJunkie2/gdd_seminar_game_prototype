extends ProgressBar

@onready var player: Player = $"../../../../.."
var label: Label = null

func _ready() -> void:
	# Créer un label pour afficher les valeurs
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(0, 0)
	label.size = size
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	add_child(label)
	
	if player:
		player.stat_changed.connect(_on_player_stat_changed)
		update_health_bar()


func _on_player_stat_changed(stat_name: String, _old_value: Variant, _new_value: Variant) -> void:
	print("entry")
	if stat_name == "HEALTH" or stat_name == "MAX_HEALTH":
		update_health_bar()


func update_health_bar() -> void:
	if not player:
		return
	
	max_value = player.MAX_HEALTH
	value = player.HEALTH
	
	# Mise à jour du texte
	if label:
		label.text = str(player.HEALTH) + " / " + str(player.MAX_HEALTH)
		label.add_theme_font_size_override("font_size", 14)
	
	# Couleur dynamique selon la vie restante
	var health_percent = (float(player.HEALTH) / float(player.MAX_HEALTH)) * 100.0
	
	if health_percent > 60:
		# Vert
		modulate = Color(0.3, 1.0, 0.3)
		if label:
			label.add_theme_color_override("font_color", Color.WHITE)
	elif health_percent > 30:
		# Orange
		modulate = Color(1.0, 0.7, 0.2)
		if label:
			label.add_theme_color_override("font_color", Color.WHITE)
	else:
		# Rouge
		modulate = Color(1.0, 0.3, 0.3)
		if label:
			label.add_theme_color_override("font_color", Color.WHITE)
