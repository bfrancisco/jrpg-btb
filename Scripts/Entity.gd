class_name Entity

# Info
var name: String
var sprite: AnimatedSprite2D # source file
var side: int # 0: Ally, 1: Enemy

# Stats
var hp: int
var max_hp: int
var charge: int = 0
var max_charge: int = 0
var spd: int
var atk: int
var def: int

var is_blocking: bool = false

# Functions
func go_idle():
	sprite.play("idle")
	is_blocking = false

func take_damage(dmg: int) -> void:
	var received_dmg = max(1, dmg - def) if is_blocking else dmg
	hp = max(hp - received_dmg, 0)
	if hp == 0:
		taken_down()

func do_block():
	is_blocking = true
	sprite.play("block")

func taken_down() -> void:
	sprite.play("dead")
	
func is_dead() -> bool:
	return (hp == 0)
	
	
