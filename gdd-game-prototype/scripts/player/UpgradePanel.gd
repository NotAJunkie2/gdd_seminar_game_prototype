extends Control

@onready var player: Player = $"../../.."
@onready var upg_1_button: Button = $GridContainer/UPG_1
@onready var upg_2_button: Button = $GridContainer/UPG_2
@onready var upg_3_button: Button = $GridContainer/UPG_3

var available_upgrades: Array[UpgradeData] = []
var current_offers: Array[UpgradeData] = []

func _ready() -> void:
	# Initially hidden
	hide()

	# Set process mode to work when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect player level up signal
	player.connect("level_up", _on_player_level_up)

	# Connect button signals
	upg_1_button.pressed.connect(_on_upgrade_selected.bind(0))
	upg_2_button.pressed.connect(_on_upgrade_selected.bind(1))
	upg_3_button.pressed.connect(_on_upgrade_selected.bind(2))

	# Initialize upgrade pool
	_initialize_upgrades()

func _initialize_upgrades() -> void:
	available_upgrades.clear()

	# Movement upgrades
	var speed_up = UpgradeData.new()
	speed_up.upgrade_name = "Speed Boost"
	speed_up.description = "Increase movement speed"
	speed_up.stat_type = "MOVE_SPEED"
	speed_up.value_change = 50.0
	available_upgrades.append(speed_up)

	# Health upgrades
	var max_health_up = UpgradeData.new()
	max_health_up.upgrade_name = "Vitality"
	max_health_up.description = "Increase max health and heal to full"
	max_health_up.stat_type = "MAX_HEALTH"
	max_health_up.value_change = 25.0
	available_upgrades.append(max_health_up)

	var heal = UpgradeData.new()
	heal.upgrade_name = "Healing"
	heal.description = "Restore health"
	heal.stat_type = "HEALTH"
	heal.value_change = 50.0
	available_upgrades.append(heal)

	var shield_up = UpgradeData.new()
	shield_up.upgrade_name = "Shield"
	shield_up.description = "Increase shield capacity"
	shield_up.stat_type = "SHIELD"
	shield_up.value_change = 15.0
	available_upgrades.append(shield_up)

	# Weapon upgrades
	var damage_up = UpgradeData.new()
	damage_up.upgrade_name = "Power Shot"
	damage_up.description = "Increase damage"
	damage_up.stat_type = "DAMAGE_MULTIPLIER"
	damage_up.value_change = 0.2
	damage_up.is_percentage = true
	available_upgrades.append(damage_up)

	var range_up = UpgradeData.new()
	range_up.upgrade_name = "Extended Barrel"
	range_up.description = "Increase projectile range"
	range_up.stat_type = "RANGE"
	range_up.value_change = 0.25
	range_up.is_percentage = true
	available_upgrades.append(range_up)

	var projectile_up = UpgradeData.new()
	projectile_up.upgrade_name = "Multi-Shot"
	projectile_up.description = "Fire additional projectiles"
	projectile_up.stat_type = "PROJECTILE_COUNT"
	projectile_up.value_change = 1.0
	available_upgrades.append(projectile_up)

	var crit_chance_up = UpgradeData.new()
	crit_chance_up.upgrade_name = "Critical Eye"
	crit_chance_up.description = "Increase critical hit chance"
	crit_chance_up.stat_type = "CRITICAL_CHANCE"
	crit_chance_up.value_change = 0.1
	available_upgrades.append(crit_chance_up)

	var crit_damage_up = UpgradeData.new()
	crit_damage_up.upgrade_name = "Critical Strike"
	crit_damage_up.description = "Increase critical damage"
	crit_damage_up.stat_type = "CRITICAL_DAMAGE"
	crit_damage_up.value_change = 0.5
	available_upgrades.append(crit_damage_up)

	var attack_speed_up = UpgradeData.new()
	attack_speed_up.upgrade_name = "Rapid Fire"
	attack_speed_up.description = "Increase attack speed"
	attack_speed_up.stat_type = "ATTACK_SPEED"
	attack_speed_up.value_change = 0.15
	attack_speed_up.is_percentage = true
	available_upgrades.append(attack_speed_up)

	# Utility upgrades
	var pickup_range_up = UpgradeData.new()
	pickup_range_up.upgrade_name = "Magnetism"
	pickup_range_up.description = "Increase XP pickup range"
	pickup_range_up.stat_type = "PICKUP_RANGE"
	pickup_range_up.value_change = 0.3
	pickup_range_up.is_percentage = true
	available_upgrades.append(pickup_range_up)

func _on_player_level_up() -> void:
	# Pause the game
	get_tree().paused = true

	# Show upgrade panel
	show()

	# Generate 3 random upgrades
	_generate_upgrade_offers()

func _generate_upgrade_offers() -> void:
	current_offers.clear()

	# Create a shuffled copy of available upgrades
	var shuffled = available_upgrades.duplicate()
	shuffled.shuffle()

	# Pick first 3 (or less if not enough upgrades)
	var count = min(3, shuffled.size())
	for i in range(count):
		current_offers.append(shuffled[i])

	# Update button texts
	if current_offers.size() > 0:
		upg_1_button.text = current_offers[0].get_display_text()
		upg_1_button.visible = true
	else:
		upg_1_button.visible = false

	if current_offers.size() > 1:
		upg_2_button.text = current_offers[1].get_display_text()
		upg_2_button.visible = true
	else:
		upg_2_button.visible = false

	if current_offers.size() > 2:
		upg_3_button.text = current_offers[2].get_display_text()
		upg_3_button.visible = true
	else:
		upg_3_button.visible = false

func _on_upgrade_selected(index: int) -> void:
	if index < current_offers.size():
		# Apply the upgrade
		current_offers[index].apply_to_player(player)

		# Hide panel
		hide()

		# Unpause game
		get_tree().paused = false

		# Clear offers
		current_offers.clear()
