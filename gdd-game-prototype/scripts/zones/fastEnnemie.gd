class_name FastEnnemie extends Ennemie


@export var Health: float = 5.0
@export var Speed: float = 150.0
@export var Damage: float = 5.0
@export var ExpValue: float = 30


func _ready() -> void:
	super._ready()
	HEALTH = Health
	SPEED = Speed
	DAMAGE = Damage
	EXPVALUE = ExpValue


func _physics_process(_delta: float) -> void:
	if player:
		print("enter")
		var direction = (player.global_position - global_position).normalized()
		linear_velocity = direction * SPEED
