extends Node2D


const ALL_ENEMIES_STR = "All Enemies"
const ANIM_SPD: float = 6.0

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
	2 : "Character going back to their place",
	3 : "Win",
	4 : "Lose",
}
var turn_queue: Array
var qi: int # index for turn_queue; char to move
var ri: int # index for turn_queue; char to receive action
var selected_action: Action
var target_position: Vector2 # for character movement animation
var orig_position: Vector2 # initial position of character that just moved

func _ready() -> void:
	state = 0
	prev_state = -1
	qi = 0
	
	for chara in characters.get_children():
		turn_queue.push_back(chara)
	turn_queue.sort_custom(func(a, b): return a.entity.spd > b.entity.spd)
	

func _physics_process(delta: float) -> void:
	if prev_state != state:
		print(debug_state[state])
	
	#print(state, qi)
	if state == 0:
		# TO DO: check if win/lose
		load_ui(turn_queue[qi])
		turn_queue[qi].entity.do_idle()
		
	elif state == 1:
		var dx = abs(turn_queue[qi].entity.sprite.position.x - target_position.x)
		var dy = abs(turn_queue[qi].entity.sprite.position.y - target_position.y)
		if dx >= 1 or dy >= 1:
			#print(turn_queue[qi].entity.sprite.position)
			#print(target_position)
			turn_queue[qi].entity.sprite.position = lerp(turn_queue[qi].entity.sprite.position, target_position, delta * ANIM_SPD)
		else:
			turn_queue[qi].entity.sprite.position = target_position
			apply_action()
			state = 2
			
	
	elif state == 2:
		var dx = abs(turn_queue[qi].entity.sprite.position.x - orig_position.x)
		var dy = abs(turn_queue[qi].entity.sprite.position.y - orig_position.y)
		if dx >= 1 or dy >= 1:
			turn_queue[qi].entity.sprite.position = lerp(turn_queue[qi].entity.sprite.position, orig_position, delta * ANIM_SPD)
		else:
			turn_queue[qi].entity.sprite.position = orig_position
			
			qi = (qi + 1) % len(turn_queue)
			
			state = 0
		
	elif state == 3:
		show_win()
	
	elif state == 4:
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

func apply_action():
	'''
	Applies effects of an action.
	qi = doer | ri = receiver | selected_action = action
	'''
	
	# If will block
	if qi == ri or selected_action.target == 2:
		turn_queue[qi].entity.do_block()
	
	# If attacks an individial enemy | on opposite sides
	elif turn_queue[qi].entity.side ^ turn_queue[ri].entity.side:
		turn_queue[qi].entity.do_attack()
		turn_queue[ri].entity.take_damage(turn_queue[qi].entity.atk)
		

func handle_select_btns(receiver_name):
	'''
	Executed when a select button is pressed.
	Turns state 0 -> 1
	'''
	# Disable buttons for the next character move
	for btn in action_btns.get_children():
		btn.button_pressed = false
		btn.visible = false
	for btn in select_btns.get_children():
		btn.button_pressed = false
		btn.visible = false
	
	# Get index of receiver of action
	var receiver_i = -1
	for i in range(len(turn_queue)):
		if turn_queue[i].entity.name == receiver_name:
			receiver_i = i
			break
	assert(receiver_i != -1)
	ri = receiver_i
	
	# Compute for orig/target positon for character movement animation
	orig_position = turn_queue[qi].entity.sprite.position
	if qi == ri or selected_action.target == 2:
		target_position = turn_queue[qi].entity.sprite.position
	else:
		var atk_rng = turn_queue[qi].entity.atk_range
		var is_ally = turn_queue[ri].entity.side == 0
		target_position.x = turn_queue[ri].entity.sprite.position.x + atk_rng * (1 if is_ally else -1)
		target_position.y = turn_queue[ri].entity.sprite.position.y
	
	state = 1

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
