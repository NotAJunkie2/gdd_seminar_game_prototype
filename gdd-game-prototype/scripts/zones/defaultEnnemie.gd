class_name DefaultEnemy extends Enemy


@export var Health: float = 10.0
@export var Speed: float = 100.0
@export var Damage: float = 10.0
@export var ExpValue: float = 25
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	super._ready()
	HEALTH = Health
	SPEED = Speed
	DAMAGE = Damage
	EXPVALUE = ExpValue
	hitbox.damaged.connect(on_damaged)


func _physics_process(_delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		
		velocity = direction * SPEED
		move_and_slide()

func on_damaged(attack: Attack) -> void:
	print("ATTACKED")
	take_damage(attack.damage)
