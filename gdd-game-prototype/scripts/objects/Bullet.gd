class_name Bullet
extends CharacterBody2D

@export var hurtbox: Hurtbox

@export var speed: float = 450
@export var damage: float = 5
@export var max_pierce: int = 1
@export var range: float = 400

var current_pierce_count: int = 0
var spawn_position: Vector2
var is_critical: bool = false

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var mesh: MeshInstance2D = $MeshInstance2D

func _ready():
	if hurtbox:
		hurtbox.hit_enemy.connect(on_enemy_hit)
	
	# Apply critical hit visual effects
	if is_critical:
		apply_critical_visuals()

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	
	velocity = direction * speed
	
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		queue_free()
	
	if (spawn_position - position).length() >= range:
		queue_free()


func on_enemy_hit():
	current_pierce_count += 1
	
	# Spawn critical hit effect on impact
	if is_critical:
		spawn_critical_hit_effect()
	
	if current_pierce_count >= max_pierce:
		queue_free()

func apply_critical_visuals() -> void:
	# Make the bullet larger
	scale = Vector2(1.5, 1.5)
	
	# Change particle color to red/orange for critical
	if particles and particles.process_material:
		var material = particles.process_material as ParticleProcessMaterial
		material.color = Color(1.0, 0.3, 0.0, 1.0) # Orange-red color
		particles.amount = 8 # More particles
	
	# Change mesh color to indicate critical
	if mesh and mesh.mesh:
		var material = mesh.mesh.surface_get_material(0) as StandardMaterial3D
		if material:
			material.albedo_color = Color(1.0, 0.2, 0.0, 1.0) # Bright orange-red
			material.emission = Color(1.0, 0.3, 0.0, 1.0)

func spawn_critical_hit_effect() -> void:
	# Create a visual effect at the hit position
	var effect = GPUParticles2D.new()
	effect.amount = 20
	effect.lifetime = 0.5
	effect.one_shot = true
	effect.explosiveness = 1.0

	# Create particle material for the critical effect
	var material = ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)
	material.spread = 180
	material.initial_velocity_min = 100
	material.initial_velocity_max = 200
	material.gravity = Vector3(0, 200, 0)
	material.scale_min = 2.0
	material.scale_max = 4.0
	material.color = Color(1.0, 0.8, 0.0, 1.0) # Yellow-orange

	effect.process_material = material
	effect.global_position = global_position

	# Add to scene
	get_tree().root.add_child(effect)

	# Auto-cleanup after animation
	await get_tree().create_timer(0.6).timeout
	if is_instance_valid(effect):
		effect.queue_free()
