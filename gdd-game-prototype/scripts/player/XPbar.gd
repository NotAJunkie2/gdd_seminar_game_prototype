extends ProgressBar

@onready var player: Player = $"../../.."

var style_bg: StyleBoxFlat
var style_fill: StyleBoxFlat
var target_value: float = 0.0
var hue_shift: float = 0.0
var base_color: Color = Color(0.0, 0.66, 0.627, 1.0)
var pulse_scale: float = 1.0

func _ready() -> void:
	max_value = player.XP_TO_NEXT_LEVEL
	value = player.CURRENT_XP
	target_value = player.CURRENT_XP
	
	style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.189, 0.174, 0.407, 0.8)
	style_bg.set_corner_radius_all(3)
	add_theme_stylebox_override("background", style_bg)
	
	style_fill = StyleBoxFlat.new()
	style_fill.bg_color = base_color
	style_fill.set_corner_radius_all(3)
	add_theme_stylebox_override("fill", style_fill)

func _process(delta: float) -> void:
	# Animate value change
	if abs(value - target_value) > 0.1:
		value = lerp(value, target_value, delta * 8.0)
	else:
		value = target_value

	# Continuous hue shift
	hue_shift += delta * 0.2
	if hue_shift > 1.0:
		hue_shift -= 1.0

	# Apply hue shift to fill color
	var hsv_color = base_color
	hsv_color.h = fmod(base_color.h + hue_shift * 0.2, 1.0)
	style_fill.bg_color = hsv_color

	# Pulse animation when gaining XP
	if pulse_scale > 1.0:
		pulse_scale = lerp(pulse_scale, 1.0, delta * 10.0)
		scale = Vector2(pulse_scale, pulse_scale)
	else:
		scale = Vector2.ONE

func _on_player_xp_changed() -> void:
	max_value = player.XP_TO_NEXT_LEVEL
	target_value = player.CURRENT_XP

	# Trigger juice effects
	pulse_scale = 1.15

	# Create a tween for extra pop
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.2, 0.1)
	tween.chain().tween_property(self, "modulate:a", 1.0, 0.2)
