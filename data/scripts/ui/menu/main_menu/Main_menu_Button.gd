extends Button

export(String) var scene_to_load


func _on_Button_pressed():
	if scene_to_load != "":
		get_tree().change_scene(scene_to_load)
	else:
		get_tree().quit()
