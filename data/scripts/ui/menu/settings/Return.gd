extends Button

#Returns to the main menu
func _on_Return_pressed():
	get_tree().change_scene("res://data/scenes/ui/menu/MainMenu.tscn")
