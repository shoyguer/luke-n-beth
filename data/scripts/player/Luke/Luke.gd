extends "res://data/scripts/player/Character.gd"

var weapon_dir

#Beginning
func _ready():
	body.play("Idle_right")
	weapon.play("Idle_right")
	right_hand.play("Idle_right")
	weapon_dir = "right"
	character = 1
	#defining character stats
	max_hp = 100
	cur_hp = 100
	max_st = 60
	cur_st = 60
	atk_rate = 0.75
	spr_atk_spd = 1 / atk_rate
	max_spd = 85
	acceleration = 1076
	cur_coin = 0
	emit_signal("started", max_hp, cur_hp, max_st, cur_st, atk_rate, max_spd, cur_coin)

#Weapon Animation and Action
func weapon(rot):
	
	#Weapon state machine
	match can_attack:
		true:
			if Input.is_action_just_pressed("mouse_left") and can_attack and !tired:
				attack_delay()
				weapon.set_speed_scale(spr_atk_spd)
				weapon.play("Swing_"+weapon_dir)
				right_hand.set_speed_scale(spr_atk_spd)
				right_hand.play("Swing_"+weapon_dir)
				state_machine("attack")
				can_regen_stamina = false
				$Stamina_regen.set_wait_time(1.5)
				$Stamina_regen.start()
				if weapon_dir == "left":
					weapon_dir = "right"
				else:
					weapon_dir = "left"
	
	#Update state to attack
	if weapon.get_frame() == 2: 
		state_machine("idle")
	
	#Facing Directions
	#Right
	if (rot == 0) or (rot >= 315) or (rot <= 45 and rot >= 0):
		facing_direction = Vector2(1, 0)
		weapon.set_z_index(1)
	#Left
	elif (rot >= 135 and rot <= 225):
		facing_direction = Vector2(-1, 0)
		weapon.set_z_index(1)
	#Down
	elif (rot < 135 and rot > 45):
		facing_direction = Vector2(0, 1)
		weapon.set_z_index(1)
	#Up
	elif (rot < 315 and rot > 225) :
		facing_direction = Vector2(0, -1)
		weapon.set_z_index(0)
	
	animation()

func equipment_animation_state():
	match state:
		"attack":
			#ring
			if equipment[5] != null:
				ring.set_speed_scale(spr_atk_spd)
				ring.play(equipment[5][7][1]+"_Swing_"+weapon_dir)
			
		"idle":
			weapon.set_speed_scale(spr_atk_spd)
			weapon.play("Idle_"+weapon_dir)
			right_hand.set_speed_scale(spr_atk_spd)
			weapon.play("Idle_"+weapon_dir)
			#ring
			if equipment[5] != null:
				ring.play(equipment[5][7][1]+"_Idle_"+weapon_dir)
