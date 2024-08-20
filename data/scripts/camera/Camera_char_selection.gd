extends Camera2D

var target

onready var liza = get_parent().get_node("Liza").position
onready var luke = get_parent().get_node("Luke").position

#Function for character selection
func set_selected(value):
	match value:
		0:
			target = liza
		
		1:
			target = luke

func _ready():
	var tilemap_rect = get_parent().get_parent().get_node("Dirt").get_used_rect()
	var tilemap_cell_size = get_parent().get_parent().get_node("Dirt").cell_size
	self.limit_left = tilemap_rect.position.x * tilemap_cell_size.x
	self.limit_right = tilemap_rect.end.x * tilemap_cell_size.x
	self.limit_top = tilemap_rect.position.y * tilemap_cell_size.y
	self.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y
	self.zoom = Vector2(0.5, 0.5)
	Stats.connect("updated_selection", self, "set_selected")
	target = liza

func _process(delta):
	self.position = target
