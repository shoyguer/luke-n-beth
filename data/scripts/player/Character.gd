extends KinematicBody2D

#Character IDs:
#	0 = Liza
#	1 = Luke
#	2 = Manuela
#	3 = John
#	4 = Arthur

#basic variables
var group = "character"
var motion = Vector2()
var facing_direction = Vector2()
var can_attack = true
var character
var is_selected
var aux
var tired = false
var is_active = false
var interact = [null, null, null]

#Body Sprites
onready var weapon = get_node("YSort").get_node("Weapon")
onready var legs = get_node("YSort").get_node("Legs")
onready var body = get_node("YSort").get_node("Body")
#Equipment Sprites
onready var ring = get_node("YSort").get_node("Weapon").get_node("Ring")
onready var right_hand = get_node("YSort").get_node("Weapon").get_node("Right_hand")

#Shader for selection
var interact_outline = preload("res://data/assets/efx/shaders/outline/outline_shader.tres")
var white_flashing = preload("res://data/assets/efx/shaders/flashing/white_flashing.tres")

#Defaults:
#max_hp = 100 (max 400)
#atk_rate min 0.3, max 2.5
#atk_rate min 0.3, max 2.5
#max_spd = 80 (min 50, max 120)
#acceleration = 950 (considering max_spd = 80)
#cur_coin max 999

var state setget state_machine
var max_hp = 0 setget update_max_hp
var cur_hp = 0 setget update_cur_hp
var max_st = 0 setget update_max_st
var cur_st = 0 setget update_cur_st
var atk_rate = 0 setget update_atk_rate
var spr_atk_spd
var max_spd = 0 setget update_max_spd
var acceleration = 0 setget update_acceleration
var cur_coin = 0 setget update_cur_coin
var can_regen_stamina

#0 Weapon Gear
#1 Head Gear
#2 Chest Gear
#3 Arms Gear
#4 Foot Gear
#5 Ring
var equipment = [null, null, null, null, null, null] setget update_equipment

#set of signals
signal started
signal max_hp_changed
signal cur_hp_changed
signal max_st_changed
signal cur_st_changed
signal cur_coin_changed
signal max_spd_changed
signal atk_rate_changed
signal change_equipment_image
signal pop_item_ui

#Setgets for updating status and misc
func update_max_hp(value):
	if (((max_hp + value) <= 400) and (max_hp + value >= 0)):
		max_hp += value
		var bars = value / 20
		emit_signal("max_hp_changed", max_hp, bars)
		if max_hp < cur_hp:
			var new_cur_hp = max_hp - cur_hp
			update_cur_hp(new_cur_hp)
		return "success"

func update_cur_hp(value):
	if value > 0:
		if (cur_hp < max_hp):
			cur_hp = clamp(cur_hp + value, 0, max_hp)
			emit_signal("cur_hp_changed", cur_hp)
			return "success"
	if value < 0:
		cur_hp = clamp(cur_hp + value, 0, max_hp)
		emit_signal("cur_hp_changed", cur_hp)
		if cur_hp <= 0:
			get_tree().reload_current_scene()
			Stats.reset()

func update_max_st(value):
	if (((max_st + value) <= 400) and (max_st + value >= 0)):
		max_st += value
		var bars = value / 20
		emit_signal("max_st_changed", max_st, bars)
		if max_st < cur_st:
			var new_cur_st = max_st - cur_st
			update_cur_hp(new_cur_st)
		return "success"

func update_cur_st(value):
	if value > 0:
		if (cur_st < max_st):
			cur_st = clamp(cur_st + value, 0, max_st)
			emit_signal("cur_st_changed", cur_st)
			return "success"
			
	if value < 0:
		cur_st = clamp(cur_st + value, 0, max_st)
		emit_signal("cur_st_changed", cur_st)
		
	if cur_st < 5:
		tired = true

func update_atk_rate(value):
	atk_rate = clamp(atk_rate + value, 0.3, 2.5)
	spr_atk_spd = 1 / atk_rate
	emit_signal("atk_rate_changed", atk_rate)

func update_max_spd(value):
	max_spd = clamp(max_spd + value, 50, 130)
	update_acceleration(max_spd)
	emit_signal("max_spd_changed", max_spd)

func update_acceleration(value):
	var result = calculator("proportion", max_spd, acceleration, 80)
	acceleration = result

func update_cur_coin(value):
	if ((cur_coin < 999) and (cur_coin + value <= 999) and cur_coin + value >= 0):
		cur_coin += value
		emit_signal("cur_coin_changed", cur_coin)
		return "success"

func update_equipment(value):
	#Emit signal to update ui equipment image
	emit_signal("change_equipment_image", value[7])
	match value[7][0]:
		"weapon":
			equipment[0] = value
		"head":
			equipment[1] = value
		"chest":
			equipment[2] = value
		"arms":
			equipment[3] = value
		"foot":
			equipment[4] = value
		"ring":
			if equipment[5] != null:
				drop_passive_item(equipment[5])
			equipment[5] = value
	equipment_animation_state()

func drop_passive_item(value):
	randomize()
	#Subtract the item status
	var index = -1
	for i in value:
		index += 1
		if i != null:
			match index:
				4:
					update_atk_rate(-i)
				5:
					update_max_spd(-i)
				6:
					update_cur_coin(-i)
	var drop = load("res://data/scenes/items/passives/pa_" + equipment[5][7][1] + \
		".tscn").instance()
	drop.position = self.position + Vector2(50.0, 0.0).rotated(randf() * TAU)
	get_parent().get_node("Pa_items").call_deferred("add_child", drop)

func calculator(type, value1, value2, value3):
	match type:
		"proportion":
			value1 = value1 * value2
			value3 = int(value1 / value3)
			var result = value3
			return result

func state_machine(value):
	state = value
	#Equipment States animation
	equipment_animation_state()

#Beginning
func _ready():
	#facing direction for the character
	facing_direction = Vector2(1,0)
	state = "idle"

#Is processing don't matter the tick rate of the game
func _physics_process(delta):
	
	if can_regen_stamina == true:
		update_cur_st(0.125)
	
	if tired == true:
		if cur_st >= max_st * 0.5:
			tired = false
	
	if Stats.selection == character:
		aux  = 1
	else:
		aux = 0.5
	
	if Stats.active_character != null:
		aux = 1
	
	self.modulate.a = lerp(self.modulate.a, aux, .1)
	
	#Make the character work if is selected
	if Stats.active_character == character:
		is_active = true
		$CanvasLayer.get_node("IngameUI").visible = true
		
		#Get rid of the outline material
		self.material = null
		
		#Will able collision
		$Collision_walk.disabled = false
		
		#Weapon Rotation
		var weapon_rotation = weapon.rotation_degrees
		weapon(weapon_rotation)
		
		weapon.look_at(get_global_mouse_position())
		
		#Movement
		var axis = get_input_axis()
		if axis == Vector2.ZERO:
			apply_friction(acceleration * delta)
		else:
			apply_movement(axis * acceleration * delta)
			
		motion = move_and_slide(motion)
		
		#Area Interaction manager
		if interact[0] != null:
			match interact[0]:
				#Change character ingame
				"character":
					if Input.is_action_just_pressed("interact"):
							Stats.active_character = interact[1]
							Stats.selection = interact[1]
							interact[2].get_node("Camera").limit_left = $Camera.limit_left
							interact[2].get_node("Camera").limit_right = $Camera.limit_right
							interact[2].get_node("Camera").limit_top = $Camera.limit_top
							interact[2].get_node("Camera").limit_bottom = $Camera.limit_bottom
							interact[2].get_node("Camera").current = true
							$Camera.current = false
		
			#Test
		if Input.is_action_just_pressed("cont_up"):
			update_max_hp(20)
		if Input.is_action_just_pressed("cont_down"):
			update_max_hp(-20)
		if Input.is_action_just_pressed("hp_up"):
			update_cur_hp(10)
		if Input.is_action_just_pressed("hp_down"):
			update_cur_hp(-10)
	else:
		#Disable collision
		$CanvasLayer.get_node("IngameUI").visible = false
		$Collision_walk.disabled = true
		interact_ereaser()
		idle_animation()

#Input axis for movement
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func apply_movement(amount):
	motion += amount
	motion = motion.clamped(max_spd)

#Bow rotation and animation
func weapon(rot):
	
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

#Character Animations
func animation():
	if motion == Vector2(0, 0):
	
		match facing_direction:
			Vector2(1, 0):
				body.flip_h = false
				body.play("Idle_right")
				legs.flip_h = false
				legs.play("none")
			
			Vector2(-1, 0):
				body.flip_h = true
				body.play("Idle_right")
				legs.flip_h = true
				legs.play("none")
			
			Vector2(0, 1):
				body.flip_h = false
				body.play("Idle_fwd")
				legs.flip_h = false
				legs.play("none")
			
			Vector2(0, -1):
				body.flip_h = false
				body.play("Idle_bwd")
				legs.flip_h = false
				legs.play("none")
	
	elif motion != Vector2(0, 0):
		
		#Right
		if facing_direction == Vector2(1, 0):
				if Input.is_action_pressed("move_right"):
					body.flip_h = false
					body.play("Body_run_right")
					legs.flip_h = false
					legs.play("Legs_run_right_right")
				elif Input.is_action_pressed("move_left"):
					body.flip_h = false
					body.play("Body_run_left")
					legs.flip_h = false
					legs.play("Legs_run_right_right")
				else:
					body.flip_h = false
					body.play("Body_run_right_fwd")
					legs.flip_h = false
					legs.play("Legs_run_right_fwd")
		
		#Left
		elif facing_direction == Vector2(-1, 0):
				if Input.is_action_pressed("move_left"):
					body.flip_h = true
					body.play("Body_run_right")
					legs.flip_h = true
					legs.play("Legs_run_right_right")
				elif Input.is_action_pressed("move_right"):
					body.flip_h = true
					body.play("Body_run_left")
					legs.flip_h = true
					legs.play("Legs_run_right_right")
				else:
					body.flip_h = true
					body.play("Body_run_right_fwd")
					legs.flip_h = true
					legs.play("Legs_run_right_fwd")
		
		#Down
		elif facing_direction == Vector2(0, 1):
				body.flip_h = false
				body.play("Body_run_fwd")
				if Input.is_action_pressed("move_right"):
					legs.flip_h = false
					legs.play("Legs_run_fwd_right")
				elif Input.is_action_pressed("move_left"):
					legs.flip_h = false
					legs.play("Legs_run_fwd_left")
				else:
					legs.flip_h = false
					legs.play("Legs_run_fwd_fwd")
		#Up
		elif facing_direction == Vector2(0, -1):
				body.flip_h = false
				body.play("Body_run_bwd")
				if Input.is_action_pressed("move_right"):
					legs.flip_h = false
					legs.play("Legs_run_fwd_right")
				elif Input.is_action_pressed("move_left"):
					legs.flip_h = false
					legs.play("Legs_run_fwd_left")
				else:
					legs.flip_h = false
					legs.play("Legs_run_fwd_fwd")

#Stop sprinting animations and makes character to being idle
func idle_animation():
	match facing_direction:
			Vector2(1, 0):
				body.flip_h = false
				body.play("Idle_right")
				legs.flip_h = false
				legs.play("none")
			
			Vector2(-1, 0):
				body.flip_h = true
				body.play("Idle_right")
				legs.flip_h = true
				legs.play("none")
			
			Vector2(0, 1):
				body.flip_h = false
				body.play("Idle_fwd")
				legs.flip_h = false
				legs.play("none")
			
			Vector2(0, -1):
				body.flip_h = false
				body.play("Idle_bwd")
				legs.flip_h = false
				legs.play("none")

#Erase all information from interact
func interact_ereaser():
	interact = [null, null, null]

#Attack delay function to call timer
func attack_delay():
	update_cur_st(-10)
	$Attack_timer.set_wait_time(atk_rate)
	$Attack_timer.start()
	can_attack = false

#Close Area collision detection entering
func _on_Collision_interacitons_area_entered(area):
	#This is the area the character is colliding with
	var area_parent = area.get_parent()
	
	#If somenone is playing with this character
	if is_active == true:
		match(area_parent.group):
			"coin":
				#Get amount of coins
				var value = area_parent.get_item()
				#Check if can update the current HP value and if it can, it returns a "success" string
				var auxf = update_cur_coin(value)
				#If success, the object will be deleted
				if auxf == "success":
					area_parent.queue_free()
			
			"passive_item":
				#Get values
				var value = area_parent.get_item()
				#Index aux for the "for" loop
				var index = -1
				#For loop for getting all values the passive item has to attribute
				for i in value:
					index += 1
					if i != null:
						match index:
							0:
								var auxa = update_max_hp(i)
							1:
								var auxa = update_cur_hp(i)
							2:
								var auxa = update_max_st(i)
							3:
								var auxa = update_cur_st(i)
							4:
								update_atk_rate(i)
							5:
								update_max_spd(i)
							6:
								update_cur_coin(i)
							7:
								update_equipment(value)
				
				area_parent.queue_free()
				#Emit pop item ui signal, then UI appears
				emit_signal("pop_item_ui", area_parent.item_name, area_parent.item_description)
			
			"hp_potion":
				#Get amount of HP to recover
				var value = area_parent.get_item()
				#Check if can update the current HP value and if it can, it returns a "success" string
				var auxf = update_cur_hp(value)
				#If success, the object will be deleted
				if auxf == "success":
					area_parent.queue_free()

func equipment_animation_state():
	pass

#On timout Can Attack
func _on_Attack_timer_timeout():
	can_attack = true

#Long Area collision detection enteringAdob
func _on_Interactions_area_entered(area):
	var area_parent = area.get_parent()
	
	if is_active == true:
		match(area_parent.group):
			
			"character":
				interact = ["character", area_parent.character, area_parent]
				area_parent.material = interact_outline

func _on_Interactions_area_exited(area):
	var area_parent = area.get_parent()
	
	if interact[0] != null:
		area_parent.material = null
		interact_ereaser()

func _on_Stamina_regen_timeout():
	can_regen_stamina = true
