extends Node2D


const ALL_ENEMIES_STR = "All Enemies"

@onready var characters: Node2D = $"../Entities"
# UI elements
@onready var char_name: RichTextLabel = $"../UI/MarginContainer/HBoxContainer/Stats/Char Name"
@onready var hp_bar: ProgressBar = $"../UI/MarginContainer/HBoxContainer/Stats/HP Bar"
@onready var charge_bar: ProgressBar = $"../UI/MarginContainer/HBoxContainer/Stats/Charge Bar"
@onready var atk_ui: RichTextLabel = $"../UI/MarginContainer/HBoxContainer/Stats/Main Stats/Atk"
@onready var def_ui: RichTextLabel = $"../UI/MarginContainer/HBoxContainer/Stats/Main Stats/Def"
@onready var spd_ui: RichTextLabel = $"../UI/MarginContainer/HBoxContainer/Stats/Main Stats/Spd"
@onready var action_btns: Node2D = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Actions/Action Btns"
@onready var select_btns: Node2D = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Select/Select Btns"
@onready var game_event: RichTextLabel = $"../UI/MarginContainer/HBoxContainer/Description/Game Event"

var prev_state: int
var state: int
var debug_state = {
	0 : "Waiting for input",
	1 : "Character animation",
	2 : "Win",
	3 : "Lose",
}
var turn_queue: Array
var qi: int # pointer/index for turn_queue
var selected_action: Action

func _ready() -> void:
	state = 0
	prev_state = -1
	qi = 0
	
	for chara in characters.get_children():
		turn_queue.push_back(chara)
	turn_queue.sort_custom(func(a, b): return a.entity.spd > b.entity.spd)
	

func _process(delta: float) -> void:
	if state == 0:
		load_ui(turn_queue[qi])
		turn_queue[qi].entity.do_idle()
		
	elif state == 1:
		pass
	
	elif state == 2:
		show_win()
	
	elif state == 3:
		show_lose()
	
	prev_state = state

func load_ui(character):
	'''Loads all information based on the current to-move character.'''
		
	char_name.text = character.entity.name
	
	hp_bar.max_value = max(1, character.entity.max_hp)
	hp_bar.value = character.entity.hp
	hp_bar.get_child(0).text = "%s/%s" % [character.entity.hp, character.entity.max_hp]
	
	charge_bar.max_value = max(1, character.entity.max_charge)
	charge_bar.value = character.entity.charge
	charge_bar.get_child(0).text = "%s/%s" % [character.entity.charge, character.entity.max_charge]
	
	atk_ui.text = "Atk: %s" % character.entity.atk
	def_ui.text = "Def: %s" % character.entity.def
	spd_ui.text = "Spd: %s" % character.entity.spd
	
	assert(len(character.actions) <= action_btns.get_child_count())
	var btn_i = 0
	for i in range(len(character.actions)):
		action_btns.get_child(i).visible = true
		action_btns.get_child(i).text = character.actions[i].name
		btn_i += 1
	while btn_i < action_btns.get_child_count():
		action_btns.get_child(btn_i).visible = false
		btn_i += 1

## BUTTON FUNCTIONS 

func show_selection(action):
	'''
	Shows possible receivers of action.
	Shows "Select Btns". 
	'''
	game_event.text = action.description
	if action.target <= 1: # if all allies or all enemies
		var btn_i = 0
		for chara in characters.get_children():
			if chara.entity.side != action.target: continue
			select_btns.get_child(btn_i).visible = true
			select_btns.get_child(btn_i).text = chara.entity.name
			btn_i += 1
		
		while btn_i < select_btns.get_child_count():
			select_btns.get_child(btn_i).visible = false
			btn_i += 1
	
	elif 2 <= action.target and action.target <= 3: # target self or all enemies
		var cur_chara = turn_queue[qi]
		select_btns.get_child(0).visible = true
		if action.target == 2:
			select_btns.get_child(0).text = cur_chara.entity.name
		elif action.target == 3:
			select_btns.get_child(0).text = ALL_ENEMIES_STR
		var btn_i = 1
		while btn_i < select_btns.get_child_count():
			select_btns.get_child(btn_i).visible = false
			btn_i += 1

func handle_action_btns(btn_emitter, btn_index):
	'''Catcher function when action buttons are pressed.'''
	for btn in action_btns.get_children():
		if btn.visible and btn != btn_emitter:
			btn.button_pressed = false
		
	var action = turn_queue[qi].actions[btn_index]
	selected_action = action
	show_selection(action)

func _on_action_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Hardcoded, refers to Action 1 Button
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Actions/Action Btns/Action 1"
		var btn_index = 0
		handle_action_btns(btn_emitter, btn_index)

func _on_action_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Hardcoded, refers to Action 1 Button
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Actions/Action Btns/Action 2"
		var btn_index = 1
		handle_action_btns(btn_emitter, btn_index)

func _on_action_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Hardcoded, refers to Action 1 Button
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Actions/Action Btns/Action 3"
		var btn_index = 2
		handle_action_btns(btn_emitter, btn_index)

func apply_action(receiver_i):
	'''
	Applies effects of an action.
	qi = doer | receiver_i = receiver | selected_action = action
	'''
	# If will block
	if qi == receiver_i or selected_action.target == 2:
		turn_queue[qi].entity.do_block()
		return
	
	
	# If attacks an individial enemy | on opposite sides
	if turn_queue[qi].entity.side ^ turn_queue[receiver_i].entity.side:
		turn_queue[qi].entity.do_attack()
		turn_queue[receiver_i].entity.take_damage(turn_queue[qi].entity.atk)
		

func handle_select_btns(receiver_name):
	'''
	Executed when a select button is pressed.
	Increments qi / turn mover function.
	'''
	var receiver_i = -1
	for i in range(len(turn_queue)):
		if turn_queue[i].entity.name == receiver_name:
			receiver_i = i
			break
	assert(receiver_i != -1)
	
	apply_action(receiver_i)
	
	for btn in action_btns.get_children():
		btn.button_pressed = false
		btn.visible = false
	for btn in select_btns.get_children():
		btn.button_pressed = false
		btn.visible = false
	
	qi = (qi + 1) % len(turn_queue)

func _on_select_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Select/Select Btns/Select 1"
		var receiver_name = btn_emitter.text
		handle_select_btns(receiver_name)

func _on_select_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Select/Select Btns/Select 2"
		var receiver_name = btn_emitter.text
		handle_select_btns(receiver_name)

func _on_select_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var btn_emitter = $"../UI/MarginContainer/HBoxContainer/Actions_Enemies/Select/Select Btns/Select 3"
		var receiver_name = btn_emitter.text
		handle_select_btns(receiver_name)




func show_win() -> void:
	pass

func show_lose() -> void:
	pass