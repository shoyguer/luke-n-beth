extends "res://data/scripts/items/passive/common/passive_item_base.gd"

func _ready():
	item_name = "pa_4_title"
	item_description = "pa_4_description"
	# value indexes
	#0 max_hp
	#1 cur_hp
	#2 max_st
	#3 cur_st
	#4 atk_rate
	#5 max_spd
	#6 cur_coin
	#7 equipable?
	value = [null, null, null, null, -0.1, null, null, ["ring", "4"]]

func get_item():
	return value
