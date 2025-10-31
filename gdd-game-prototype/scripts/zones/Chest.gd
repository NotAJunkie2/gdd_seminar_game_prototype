class_name Chest extends Area2D

signal chest_opened

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_opened: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	create_visual_effect()
	print("=== CHEST READY ===")
	print("Chest spawned at position: ", global_position)
	print("Chest collision_layer: ", collision_layer, " collision_mask: ", collision_mask)
	print("Chest monitoring: ", monitoring, " monitorable: ", monitorable)


func _on_body_entered(body: Node2D) -> void:
	print("Body entered chest area: ", body.name, " (is Player: ", body is Player, ")")
	if body is Player and not is_opened:
		print("Opening chest!")
		open_chest()


func open_chest() -> void:
	print("entry chest")
	is_opened = true
	
	# Attendre que l'upgrade soit choisi avant de faire disparaître le coffre
	await show_upgrade_choices()
	
	# Animation de disparition du coffre
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3).set_delay(0.3)
	tween.tween_property(sprite, "rotation", TAU, 0.6)
	
	await tween.finished
	queue_free()


func show_upgrade_choices() -> void:
	# Pause avant d'afficher pour éviter les problèmes de timing
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var upgrade_panel = player.get_node_or_null("Camera2D/EnemyHud/UpgradeOnLVLUp")
		if upgrade_panel:
			print("Opening upgrade panel...")
			upgrade_panel.visible = true
			upgrade_panel._generate_upgrade_offers()
			await upgrade_panel.upgrade_chosen
			print("Upgrade chosen!")
		else:
			print("ERROR: UpgradePanel not found at path: Camera2D/EnemyHud/UpgradeOnLVLUp")
			get_tree().paused = false
	else:
		print("ERROR: Player not found!")
		get_tree().paused = false
	
	chest_opened.emit()


func create_visual_effect() -> void:
	# Animation de rebond
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", -15, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", 0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Animation de lueur dorée
	var glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(sprite, "modulate", Color(2.0, 1.8, 0.5), 0.6).set_trans(Tween.TRANS_SINE)
	glow_tween.tween_property(sprite, "modulate", Color(1.2, 1.0, 0.3), 0.6).set_trans(Tween.TRANS_SINE)
	
	# Animation de scale pour attirer l'attention
	var scale_tween = create_tween()
	scale_tween.set_loops()
	scale_tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.8).set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
