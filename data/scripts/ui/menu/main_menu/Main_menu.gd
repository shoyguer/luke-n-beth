extends Control

#func _ready():
	#for button in $Lines/Columns/Page_1.get_children():
		#button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
		
#func _on_Button_pressed(scene):
	#if scene != "":
		#get_tree().change_scene(scene)
	#else:
		#get_tree().quit()
