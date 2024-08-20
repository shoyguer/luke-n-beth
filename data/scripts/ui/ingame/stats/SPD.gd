extends Label

onready var character = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready():
	character.connect("started", self, "started")
	character.connect("max_spd_changed", self, "update_value")

func started(a, b, c, e, f, spd, g):
	self.text = String(spd)

func update_value(spd):
	self.text = String(spd)
