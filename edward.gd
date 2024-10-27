extends Node2D

var entity: Entity = Entity.new()
var actions: Array
var side = 0

func _ready() -> void:
	#info
	entity.name = "Edward"
	entity.sprite = $"AnimSprite"
	entity.side = 0
	
	#stats
	entity.hp = 85
	entity.max_hp = 85
	entity.charge = 3
	entity.max_charge = 6
	entity.spd = 6
	entity.atk = 13
	entity.def = 3
	
	var atk_action = Action.new()
	atk_action.name = "Swing"
	atk_action.target = 1
	atk_action.charge_cost = 0
	atk_action.charge_gain = 1
	atk_action.description = "Swings at a target"
	actions.push_back(atk_action)
	
	var block_action = Action.new()
	block_action.name = "Block"
	block_action.target = 2
	block_action.charge_cost = 0
	block_action.charge_gain = 2
	block_action.description = "Blocks incoming attack."
	actions.push_back(block_action)
	
	var special_action = Action.new()
	special_action.name = "Healing Light"
	special_action.target = 3
	special_action.charge_cost = 6
	special_action.charge_gain = 0
	special_action.description = "Heals the party."
	actions.push_back(special_action)
	
	entity.do_idle()
