extends Control

onready var selection_camera = get_parent().get_node("Camera_char_selection")
var char_camera

func _ready():
	Stats.connect("updated_selection", self, "set_selected")
	set_selected(Stats.selection)

func set_selected(value):
	match value:
		0:
			$Liza.modulate.a = 1
			$Luke.modulate.a = 0.7
			char_camera = get_parent().get_node("Liza").get_node("Camera")
		
		1:
			$Luke.modulate.a = 1
			$Liza.modulate.a = 0.7
			char_camera = get_parent().get_node("Luke").get_node("Camera")

func _physics_process(delta):
	
	if Input.is_action_just_pressed("move_right"):
		Stats.update_selection(1)
	elif Input.is_action_just_pressed("move_left"):
		Stats.update_selection(-1)
	
	if Input.is_action_just_pressed("interact"):
		Stats.active_character = Stats.selection
		char_camera.limit_left = selection_camera.limit_left
		char_camera.limit_right = selection_camera.limit_right
		char_camera.limit_top = selection_camera.limit_top
		char_camera.limit_bottom = selection_camera.limit_bottom
		char_camera.zoom = selection_camera.zoom
		char_camera.current = true
		selection_camera.queue_free()
		self.queue_free()
