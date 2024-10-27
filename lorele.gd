extends Node2D

var entity: Entity = Entity.new()
var actions: Array

func _ready() -> void:
	#info
	entity.name = "Lorele"
	entity.sprite = $"AnimSprite"
	entity.side = 0
	
	#stats
	entity.hp = 120
	entity.max_hp = 120
	entity.charge = 2
	entity.max_charge = 3
	entity.spd = 11
	entity.atk = 13
	entity.def = 5
	
	# Actions
	var atk_action = Action.new()
	atk_action.name = "Punch"
	atk_action.target = 1
	atk_action.charge_cost = 0
	atk_action.charge_gain = 1
	atk_action.description = "Punches a target."
	actions.push_back(atk_action)

	var block_action = Action.new()
	block_action.name = "Block"
	block_action.target = 2
	block_action.charge_cost = 0
	block_action.charge_gain = 2
	block_action.description = "Blocks incoming attack."
	actions.push_back(block_action)
	
	var special_action = Action.new()
	special_action.name = "Sucker Punch"
	special_action.target = 1
	special_action.charge_cost = 2
	special_action.charge_gain = 0
	special_action.description = "Stuns an enemy."
	actions.push_back(special_action)
	
	entity.do_idle()
