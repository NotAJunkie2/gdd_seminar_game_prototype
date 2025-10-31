extends Node2D

var star_count: int = 150
var stars: Array = []

func _ready() -> void:
	create_stars()


func create_stars() -> void:
	for i in range(star_count):
		var star = create_star()
		stars.append(star)
		add_child(star)


func create_star() -> Node2D:
	var star_node = Node2D.new()
	var star_rect = ColorRect.new()
	
	# Taille aléatoire
	var size = randf_range(1.0, 3.0)
	star_rect.custom_minimum_size = Vector2(size, size)
	star_rect.size = Vector2(size, size)
	
	# Couleur blanche avec alpha aléatoire
	var alpha = randf_range(0.3, 1.0)
	star_rect.color = Color(1, 1, 1, alpha)
	
	# Position aléatoire dans l'écran
	star_node.position = Vector2(
		randf_range(-640, 640),
		randf_range(-360, 360)
	)
	
	star_node.add_child(star_rect)
	
	# Animation de scintillement
	create_twinkle_animation(star_rect)
	
	return star_node


func create_twinkle_animation(star: ColorRect) -> void:
	var tween = create_tween()
	tween.set_loops()
	
	var duration = randf_range(1.5, 3.0)
	var target_alpha = randf_range(0.2, 0.6)
	
	tween.tween_property(star, "modulate:a", target_alpha, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(star, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	# Faire suivre les étoiles par rapport à la caméra
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.global_position
