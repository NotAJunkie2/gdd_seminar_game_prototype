class_name FastEnemy extends Enemy


@export var Health: float = 5.0
@export var Speed: float = 150.0
@export var Damage: float = 5.0
@export var ExpValue: float = 30


func _ready() -> void:
	super._ready()
	HEALTH = Health
	MAX_HEALTH = Health
	SPEED = Speed
	DAMAGE = Damage
	EXPVALUE = ExpValue


func _physics_process(_delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
