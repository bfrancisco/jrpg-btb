extends Node2D

var entity: Entity = Entity.new()
var actions: Array

@onready var healthbar = $"HP Bar"
@onready var hp_label = $"HP Bar/Label"

func _ready() -> void:
	# Info
	entity.name = "Domino"
	entity.sprite = $AnimSprite
	entity.side = 0
	
	# Stats
	entity.hp = 85
	entity.max_hp = 85
	entity.charge = 2
	entity.max_charge = 3
	entity.spd = 15
	entity.atk = 40
	entity.def = 5
	entity.atk_range = 160
	entity.crit_rate = 35
	entity.prio_action = 1

	
	
	healthbar.global_position = entity.sprite.global_position + Vector2(-30, 40)
	healthbar.max_value = entity.max_hp
	healthbar.value = entity.hp
	hp_label.text = "%s/%s" % [entity.hp, entity.max_hp]
	
	# Actions
	var atk_action = Action.new()
	atk_action.name = "Knife Throw"
	atk_action.target = 1
	atk_action.charge_cost = 0
	atk_action.charge_gain = 1
	atk_action.description = "Throws a knife to a target."
	actions.push_back(atk_action)
	
	var block_action = Action.new()
	block_action.name = "Block"
	block_action.target = 2
	block_action.charge_cost = 0
	block_action.charge_gain = 2
	block_action.description = "Blocks incoming attack."
	actions.push_back(block_action)
	
	var special_action = Action.new()
	special_action.name = "Blade Dance"
	special_action.target = 1
	special_action.charge_cost = 3
	special_action.charge_gain = 0
	special_action.description = "Throws multiple knives until exhaustion."
	actions.push_back(special_action)
	
	entity.do_idle()
	
func _process(delta: float) -> void:
	healthbar.value = entity.hp
	hp_label.text = "%s/%s" % [entity.hp, entity.max_hp]
