extends Control


onready var character = get_parent().get_parent().get_parent()

var fade_container = preload("res://data/scenes/efx/ui/Fade_in_health_container.tscn")

#On ready calling the max_health function to draw the health containers and also connecting
#the signals from global health
func _ready():
	character.connect("started", self, "started")
	character.connect("max_hp_changed", self, "set_max_health_bar")
	character.connect("cur_hp_changed", self, "set_cur_health_bar")

#Makes UI visible when player is selected
func started(max_health, cur_health, b, c, d, e, f):
	$Bar.max_value = max_health
	$Bar.value = cur_health
	$Bar.rect_size.x = (14 * (max_health / 20))
	$Under_end.rect_position.x = $Bar.rect_position.x + $Bar.rect_size.x
	$Lines.rect_size.x = $Bar.rect_size.x

#Show bar and calling set_cur to draw the progress bar
func set_max_health_bar(value, bars):
	
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
		$Bar.rect_size.x = (14 * (value / 20))
		$Under_end.rect_position.x = $Bar.rect_position.x + $Bar.rect_size.x
		$Lines.rect_size.x = $Bar.rect_size.x
		
		#Animation getting max health
		if change == "positive":
			var fade_container_instance = fade_container.instance()
			var fade = fade_container_instance.get_node("Fade_in")
			fade.rect_size.x = 14 * bars
			fade_container_instance.rect_position.x = $Bar.rect_position.x + old_bar_value
			fade_container_instance.rect_position.y = $Bar.rect_position.y
			fade.visible = true
			add_child(fade_container_instance)
		
		if change == "negative":
			var fade_container_instance = fade_container.instance()
			var fade = fade_container_instance.get_node("Fade_out")
			fade.rect_size.x = 14 * -bars
			fade_container_instance.rect_position.x = $Bar.rect_position.x + $Bar.rect_size.x
			fade_container_instance.rect_position.y = $Bar.rect_position.y
			fade.visible = true
			add_child(fade_container_instance)

#Show current health
func set_cur_health_bar(value):
	
	if Stats.active_character != null:
		
		#Draw full healths bars
		$Bar.value = value
	
		if $Bar.value <= ($Bar.max_value * 0.25):
			$Symbol.play("pulse")
			$Symbol.set_speed_scale(1)
			if $Bar.value <= ($Bar.max_value * 0.125):
				$Symbol.set_speed_scale(1.5)
		else:
			$Symbol.play("idle")
