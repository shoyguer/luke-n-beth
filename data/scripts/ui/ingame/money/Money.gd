extends Label

onready var character = get_parent().get_parent().get_parent().get_parent()

func _ready():
	character.connect("cur_coin_changed", self, "set_coin")

func set_coin(value):
	self.text = String(value)
