extends MarginContainer

onready var character = get_parent().get_parent().get_parent()
onready var ring = $GridContainer/Ring
onready var head = $GridContainer/Head
onready var magic = $GridContainer/Magic
onready var arms = $GridContainer/Arms
onready var chest = $GridContainer/Chest
onready var weapon = $GridContainer/Weapon
onready var foot = $GridContainer/Foot

func _ready():
	character.connect("change_equipment_image", self, "change_equipment_images")
	
func change_equipment_images(value):
	match value[0]:
		"weapon":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			weapon.texture = texture
		"head":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			head.texture = texture
		"chest":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			chest.texture = texture
		"arms":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			arms.texture = texture
		"foot":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			foot.texture = texture
		"ring":
			var texture = load("res://data/assets/items/passives/common/" + value[1] + ".png")
			ring.texture = texture
