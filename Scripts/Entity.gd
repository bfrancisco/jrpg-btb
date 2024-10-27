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
var atk_range: int = 80
var crit_rate: int = 10

var is_blocking: bool = false

var rng = RandomNumberGenerator.new()

# Functions
func do_idle():
	sprite.play("idle")
	is_blocking = false

func take_damage(dmg: int) -> void:
	var received_dmg = max(1, dmg - def) if is_blocking else dmg
	if rng.randi_range(1, 100) <= crit_rate:
		received_dmg *= 2
		# have some signal here to indicate critical hit
	hp = max(hp - received_dmg, 0)
	sprite.play("hurt")
	
	if hp == 0:
		taken_down()

func do_block():
	is_blocking = true
	sprite.play("block")
	
func do_attack():
	sprite.play("attack")

func update_charge(to_add):
	assert(charge + to_add >= 0)
	charge = min(charge + to_add, max_charge)

func taken_down() -> void:
	sprite.play("dead")
	
func is_dead() -> bool:
	return (hp == 0)
	
func do_special():
	sprite.play("special")
