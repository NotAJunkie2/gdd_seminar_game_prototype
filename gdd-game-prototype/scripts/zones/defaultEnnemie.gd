class_name DefaultEnnemie extends Ennemie


@export var Health: float = 10.0
@export var Speed: float = 100.0
@export var Damage: float = 10.0
@export var ExpValue: float = 25


func _ready() -> void:
	super._ready()
	HEALTH = Health
	SPEED = Speed
	DAMAGE = Damage
	EXPVALUE = ExpValue


func _physics_process(_delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		linear_velocity = direction * SPEED
