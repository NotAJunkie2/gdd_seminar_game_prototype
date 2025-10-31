class_name Chest extends Area2D

signal chest_opened

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_opened: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	create_visual_effect()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_opened:
		open_chest()


func open_chest() -> void:
	is_opened = true
	
	show_upgrade_choices()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3).set_delay(0.3)
	tween.tween_property(sprite, "rotation", TAU, 0.6)
	
	await tween.finished
	queue_free()


func show_upgrade_choices() -> void:
	chest_opened.emit()


func create_visual_effect() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", -10, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", 0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
	glow_tween.tween_property(sprite, "modulate", Color.WHITE, 0.8).set_trans(Tween.TRANS_SINE)
