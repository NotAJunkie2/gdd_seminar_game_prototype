class_name Player extends CharacterBody2D

# PLAYER
@export var MOVE_SPEED: float = 250
@export var ACCELERATION: float = 1500.0
@export var DECELERATION: float = 2000.0
@export var MAX_HEALTH: int = 100
@export var HEALTH: int = 100
@export var SHIELD: int = 25
# WEAPON STATS
@export var DAMAGE_MULTIPLIER = 1.0
@export var RANGE: float = 1.0
@export var PROJECTILE_COUNT: int = 1
@export var CRITICAL_CHANCE: float = 0.0
@export var CRITICAL_DAMAGE: float = 1.15
@export var ATTACK_SPEED: float = 1.0
# EXP PICKUP RANGE
@export var PICKUP_RANGE: float = 1.0
@export var LEVEL: int = 1
@export var CURRENT_XP: float = 0.0
@export var XP_TO_NEXT_LEVEL: float = 100.0

@onready var MOVEMENT_FSM: StateMachine = $movement_fsm
@onready var MOVEMENT_CMP: MovementComponent = $movement_component
@onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

@export var aim_position: Vector2 = Vector2(1, 0)
@onready var pickup_magnet: Area2D = $PickupMagnet
@onready var sprite: Sprite2D = $Sprite
@onready var death_screen: Control = $Camera2D/EnemyHud/DeathScreen

var is_dead: bool = false

signal xp_changed
signal level_up
signal stat_changed(stat_name: String, old_value: Variant, new_value: Variant)
signal player_died

func _init() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	MOVEMENT_FSM.process_input(event)

	if event is InputEventMouseMotion:
		var half_viewport = get_viewport_rect().size / 2.0
		aim_position = (event.position - half_viewport)

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())

	MOVEMENT_FSM.process_physics(delta)
	move_and_slide()

func _process(delta: float) -> void:
	MOVEMENT_FSM.process_frame(delta)

func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pickup") and area is Pickup:
		area.collect()
		pass
	pass # Replace with function body.


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pickup"):
		(area as Pickup).FOLLOW_PLAYER = true
		pass
	pass # Replace with function body.


func take_damage(value: float) -> void:
	if is_dead:
		return
		
	var old_health = HEALTH
	HEALTH -= int(value)
	stat_changed.emit("HEALTH", old_health, HEALTH)
	
	if HEALTH <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	print("Player died!")
	
	# Disable movement and collisions
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	# Play death animation
	play_death_animation()
	
	# Wait for animation to complete
	await get_tree().create_timer(1.5).timeout
	
	# Pause the game
	get_tree().paused = true
	
	# Show death screen
	if death_screen and death_screen.has_method("show_death_screen"):
		death_screen.show_death_screen()
	
	# Emit signal
	player_died.emit()

func play_death_animation() -> void:
	if not sprite:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_CUBIC)
	
	# Rotate and scale down
	tween.tween_property(sprite, "rotation", TAU * 2, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2(0.2, 0.2), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Move down slightly
	tween.tween_property(self, "position:y", position.y + 50, 1.0).set_trans(Tween.TRANS_QUAD)

func addXP(xp: float) -> void:
	CURRENT_XP += xp

	if CURRENT_XP >= XP_TO_NEXT_LEVEL:
		CURRENT_XP -= XP_TO_NEXT_LEVEL
		XP_TO_NEXT_LEVEL = XP_TO_NEXT_LEVEL * 1.5
		LEVEL += 1
		level_up.emit()
	xp_changed.emit()
	pass

func modify_stat(stat_name: String, value: float, is_percentage: bool = false) -> void:
	var old_value: Variant
	var new_value: Variant

	match stat_name:
		"MOVE_SPEED":
			old_value = MOVE_SPEED
			if is_percentage:
				MOVE_SPEED *= (1.0 + value)
			else:
				MOVE_SPEED += value
			new_value = MOVE_SPEED
		"MAX_HEALTH":
			old_value = MAX_HEALTH
			if is_percentage:
				MAX_HEALTH = int(MAX_HEALTH * (1.0 + value))
			else:
				MAX_HEALTH += int(value)
			HEALTH = MAX_HEALTH # Heal to full
			new_value = MAX_HEALTH
		"HEALTH":
			old_value = HEALTH
			HEALTH = min(HEALTH + int(value), MAX_HEALTH)
			new_value = HEALTH
		"SHIELD":
			old_value = SHIELD
			if is_percentage:
				SHIELD = int(SHIELD * (1.0 + value))
			else:
				SHIELD += int(value)
			new_value = SHIELD
		"DAMAGE_MULTIPLIER":
			old_value = DAMAGE_MULTIPLIER
			if is_percentage:
				DAMAGE_MULTIPLIER *= (1.0 + value)
			else:
				DAMAGE_MULTIPLIER += value
			new_value = DAMAGE_MULTIPLIER
		"RANGE":
			old_value = RANGE
			if is_percentage:
				RANGE *= (1.0 + value)
			else:
				RANGE += value
			new_value = RANGE
		"PROJECTILE_COUNT":
			old_value = PROJECTILE_COUNT
			PROJECTILE_COUNT += int(value)
			new_value = PROJECTILE_COUNT
		"CRITICAL_CHANCE":
			old_value = CRITICAL_CHANCE
			if is_percentage:
				CRITICAL_CHANCE *= (1.0 + value)
			else:
				CRITICAL_CHANCE += value
			new_value = CRITICAL_CHANCE
		"CRITICAL_DAMAGE":
			old_value = CRITICAL_DAMAGE
			if is_percentage:
				CRITICAL_DAMAGE *= (1.0 + value)
			else:
				CRITICAL_DAMAGE += value
			new_value = CRITICAL_DAMAGE
		"ATTACK_SPEED":
			old_value = ATTACK_SPEED
			if is_percentage:
				ATTACK_SPEED *= (1.0 + value)
			else:
				ATTACK_SPEED += value
			new_value = ATTACK_SPEED
		"PICKUP_RANGE":
			old_value = PICKUP_RANGE
			if is_percentage:
				PICKUP_RANGE *= (1.0 + value)
			else:
				PICKUP_RANGE += value
			new_value = PICKUP_RANGE
			pickup_magnet.scale *= PICKUP_RANGE

	print("Stat ", stat_name, " changed from ", old_value, " to ", new_value)
	stat_changed.emit(stat_name, old_value, new_value)
