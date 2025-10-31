extends Control

@onready var restart_button: Button = $GridContainer/Button
@onready var color_rect: ColorRect = $ColorRect
@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	# Initially hidden
	hide()
	
	# Set process mode to work when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect restart button
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Start with transparent elements for animation
	modulate.a = 0.0

func show_death_screen() -> void:
	show()
	
	# Animate the death screen appearing
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in the screen
	tween.tween_property(self, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# Scale in the grid container with elastic bounce
	grid_container.scale = Vector2(0.5, 0.5)
	tween.tween_property(grid_container, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_delay(0.3)

func _on_restart_pressed() -> void:
	# Animate out before restarting
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# Unpause game
	get_tree().paused = false
	
	# Restart the current scene
	get_tree().reload_current_scene()
