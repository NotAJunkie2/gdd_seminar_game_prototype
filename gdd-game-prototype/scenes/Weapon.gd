class_name BasicWeapon extends Node2D

@export var FIRING_POSITION : Marker2D
@export var BULLET_SCENE : PackedScene = preload("res://Scenes/Bullet.tscn")
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
		
		var spawned_bullet := BULLET_SCENE.instantiate()
		var mouse_direction := get_global_mouse_position() - FIRING_POSITION.global_position
		
		get_tree().root.add_child(spawned_bullet)
		spawned_bullet.spawn_position = FIRING_POSITION.global_position
		spawned_bullet.global_position = FIRING_POSITION.global_position
		spawned_bullet.rotation = mouse_direction.angle()

		CAN_FIRE = false
		FIRE_COOLDOWN_TIMER.start(FIRE_COOLDOWN / PLAYER.ATTACK_SPEED)
	
	#for strategy in PLAYER.WEAPON_UPGRADES:
		#strategy.apply_upgrade(spawned_bullet)


func _on_cooldown_timeout() -> void:
	CAN_FIRE = true
	pass # Replace with function body.
