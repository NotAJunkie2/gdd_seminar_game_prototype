class_name SlowEnnemie extends Ennemie


@export var Health: float = 20.0
@export var Speed: float = 50.0
@export var Damage: float = 15.0
@export var ExpValue: float = 50


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
