class_name BasicWeapon extends Node2D

@export var FIRING_POSITION: Marker2D
@export var BULLET_SCENE: PackedScene = preload("res://Scenes/Bullet.tscn")
@onready var FIRE_COOLDOWN_TIMER: Timer = $Cooldown

var PLAYER: Player
var FIRE_COOLDOWN: float = 0.35
var CAN_FIRE: bool = true

func _ready() -> void:
	PLAYER = get_owner()

func _physics_process(_delta: float) -> void:
	if CAN_FIRE:
		shoot()

func shoot() -> void:
	if Input.is_action_pressed("primary_fire"):
		if sign(PLAYER.aim_position.x) != sign(FIRING_POSITION.position.x):
			FIRING_POSITION.position.x *= -1

		var mouse_direction := get_global_mouse_position() - FIRING_POSITION.global_position
		var projectile_count = PLAYER.PROJECTILE_COUNT
		
		# Calculate spacing between bullets (perpendicular to firing direction)
		var spacing = 15.0 # Pixels between each bullet
		var perpendicular = mouse_direction.rotated(PI / 2).normalized()
		
		# Calculate starting offset for centered spread
		var total_width = (projectile_count - 1) * spacing
		var start_offset = - total_width / 2.0

		# Spawn multiple bullets
		for i in range(projectile_count):
			var spawned_bullet := BULLET_SCENE.instantiate()
			
			# Calculate position offset for this bullet
			var offset = start_offset + (i * spacing)
			var bullet_position = FIRING_POSITION.global_position + perpendicular * offset
			
			# Calculate if this bullet is a critical hit
			var is_crit = randf() < PLAYER.CRITICAL_CHANCE
			var bullet_damage = damage_multiplier_calculation(is_crit)
	
			get_tree().root.add_child(spawned_bullet)
			spawned_bullet.spawn_position = bullet_position
			spawned_bullet.global_position = bullet_position
			spawned_bullet.rotation = mouse_direction.angle()
			spawned_bullet.range *= PLAYER.RANGE
			spawned_bullet.damage = bullet_damage
			spawned_bullet.is_critical = is_crit

		CAN_FIRE = false
		FIRE_COOLDOWN_TIMER.start(FIRE_COOLDOWN / PLAYER.ATTACK_SPEED)

	#for strategy in PLAYER.WEAPON_UPGRADES:
		#strategy.apply_upgrade(spawned_bullet)

func damage_multiplier_calculation(is_critical: bool) -> float:
	var base_damage = 5.0 * PLAYER.DAMAGE_MULTIPLIER

	if is_critical:
		return base_damage * PLAYER.CRITICAL_DAMAGE
	else:
		return base_damage


func _on_cooldown_timeout() -> void:
	CAN_FIRE = true
	pass # Replace with function body.
