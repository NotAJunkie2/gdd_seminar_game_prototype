class_name SEnemy extends Enemy


@export var Health: float = 20.0
@export var Speed: float = 50.0
@export var Damage: float = 15.0
@export var ExpValue: float = 50


func _ready() -> void:
	super._ready()
	HEALTH = Health
	MAX_HEALTH = Health
	SPEED = Speed
	DAMAGE = Damage
	EXPVALUE = ExpValue
	print("SlowEnemy ready - Damage: ", DAMAGE, " | Hitbox exists: ", hitbox != null)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)  # Appeler le système de dégâts de la classe parente
	
	if not player:
		player = get_tree().get_first_node_in_group("Player")
	
	if player:
		look_at(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
