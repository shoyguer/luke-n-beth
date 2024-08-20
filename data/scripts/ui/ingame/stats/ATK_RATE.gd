extends Label

onready var character = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready():
	character.connect("started", self, "started")
	character.connect("atk_rate_changed", self, "update_value")

func started(a, b, c, d, atk_rate, e, f):
	self.text = String(atk_rate)

func update_value(atk_rate):
	self.text = String(atk_rate)
