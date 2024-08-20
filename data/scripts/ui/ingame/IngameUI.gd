extends Control

func _ready():
	Stats.connect("updated_selection", self, "set_active")

func set_active():
	self.visible = true
