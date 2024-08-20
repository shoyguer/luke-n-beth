extends StaticBody2D

var group = "passive_item"
var item_name = ""
var item_description = ""
#0 value indexes
#1 max_hp
#2 cur_hp
#3 atk_rate
#4 max_spd
#5 cur_coin
#6 equipable?
var value = [null, null, null, null, null, null]

func get_item():
	return value
