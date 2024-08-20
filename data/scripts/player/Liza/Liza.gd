extends "res://data/scripts/player/Character.gd"

var bow_charging = false
var arrow_force = 0
var shader_value = 0.01
var shader_target = 1
var arrow = preload("res://data/scenes/weapons/arrow/Simple_arrow.tscn")

onready var end_of_bow = get_node("YSort").get_node("Weapon").get_node("End_of_bow")

#Beginning
func _ready():
	body.play("Idle_right")
	character = 0
	#defining character stats
	max_hp = 80
	cur_hp = 80
	max_st = 80
	cur_st = 80
	atk_rate = 1
	spr_atk_spd = 1 / atk_rate
	max_spd = 75
	acceleration = 950
	cur_coin = 0
	emit_signal("started", max_hp, cur_hp, max_st, cur_st, atk_rate, max_spd, cur_coin)
	ring.position = right_hand.position

func _physics_process(delta):
	#White flashing shader for Bow
	if weapon.get_frame() == 3: 
		weapon.material = white_flashing
		update_cur_st(-0.075)
		if shader_value >= 0.99:
			shader_target = 0
			
		elif shader_value <= 0.01:
			shader_target = 1
			
		shader_value = lerp(shader_value, shader_target, .15)
		weapon.material.set_shader_param("white_opacity", shader_value)
	else:
		weapon.material = null
		shader_value = 0.01
		shader_target = 1

#Weapon Animation and Action
func weapon(rot):
	
	#Bow state machine
	match can_attack:
		true:
			if Input.is_action_pressed("mouse_left") and can_attack and !tired:
				weapon.set_speed_scale(spr_atk_spd)
				right_hand.set_speed_scale(spr_atk_spd)
				weapon.play("Charge")
				right_hand.play("Charge")
				bow_charging = true
				state_machine("charging")
				can_regen_stamina = false
				
			elif Input.is_action_just_released("mouse_left") and bow_charging and weapon.get_frame() == 3:
				shoot(rot)
				weapon.play("Empty")
				right_hand.play("Idle")
				attack_delay()
				bow_charging = false
				state_machine("idle")
				can_regen_stamina = false
				$Stamina_regen.set_wait_time(1.5)
				$Stamina_regen.start()
				
			elif Input.is_action_just_released("mouse_left") and bow_charging and weapon.get_frame() <= 2:
				weapon.play("Idle")
				right_hand.play("Idle")
				bow_charging = false
				state_machine("idle")
				can_regen_stamina = false
				$Stamina_regen.set_wait_time(1.5)
				$Stamina_regen.start()
				
			else:
				weapon.play("Idle")
				right_hand.play("Idle")
				
		false:
			weapon.play("Empty")
	
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
		"charging":
			#ring
			if equipment[5] != null:
				ring.set_speed_scale(spr_atk_spd)
				ring.play(equipment[5][7][1]+"_Charge")
				
		"idle":
			#ring
			if equipment[5] != null:
				ring.set_speed_scale(spr_atk_spd)
				ring.play(equipment[5][7][1]+"_Idle")

#Function for shooting arrow
func shoot(rot):
	
	#Arrow Force calculation
	match weapon.get_frame():
		2:
			arrow_force = 250
		3:
			arrow_force = 350
	
	var arrow_instance = arrow.instance()
	arrow_instance.position = self.global_position
	arrow_instance.get_node("Shadow").rotation_degrees = rot
	arrow_instance.get_node("Arrow").rotation_degrees = rot
	get_parent().get_node("Projectiles").add_child(arrow_instance)
	arrow_instance.apply_impulse(Vector2(), Vector2(350, 0).rotated(weapon.rotation))
