extends Node

#Set of variables
var active_character = null
var selection = 0 setget update_selection
var player = 1
var total_characters = 2

signal updated_selection

func update_selection(value):
	if value == 0:
		selection = 0
	else:
		selection += value
		if selection > (total_characters - 1):
			selection = 0
		if selection < 0:
			selection = total_characters - 1
	emit_signal("updated_selection", selection)

func reset():
	update_selection(0)
	active_character = null
