extends Control


onready var character = get_parent().get_parent().get_parent()

#var fade_container = preload("res://data/scenes/efx/ui/Fade_in_stamina_container.tscn")

#On ready calling the max_stamina function to draw the stamina containers and also connecting
#the signals from global stamina
func _ready():
	character.connect("started", self, "started")
	character.connect("max_st_changed", self, "set_max_stamina_bar")
	character.connect("cur_st_changed", self, "set_cur_stamina_bar")

#Makes UI visible when player is selected
func started(a, b, max_stamina, cur_stamina, c, d, e):
	$Bar.max_value = max_stamina
	$Bar.value = cur_stamina
	$Bar.rect_size.x = (12 * (max_stamina / 20))
	$Under_end.rect_position.x = $Bar.rect_position.x + $Bar.rect_size.x
	$Lines.rect_size.x = $Bar.rect_size.x

#Show bar and calling set_cur to draw the progress bar
func set_max_stamina_bar(value, bars):
	
	var old_bar_value
	
	if Stats.active_character != null:
		
		var change
		if bars < 0:
			change = "negative"
		else:
			change = "positive"
		
		#Draw current under bar
		$Bar.max_value = value
		old_bar_value = $Bar.rect_size.x
		$Bar.rect_size.x = (12 * (value / 20))
		$Under_end.rect_position.x = 16 + $Bar.rect_size.x
		$Lines.rect_size.x = $Bar.rect_size.x

#Show current stamina
func set_cur_stamina_bar(value):
	
	if Stats.active_character != null:
		
		#Draw full staminas bars
		$Bar.value = value
		
		if $Bar.value <= ($Bar.max_value * 0.25) and !character.tired:
			$Symbol.play("pulse")
			$Symbol.set_speed_scale(1)
		elif character.tired:
			$Symbol.play("pulse")
			$Symbol.set_speed_scale(1.5)
		else:
			$Symbol.play("idle")
