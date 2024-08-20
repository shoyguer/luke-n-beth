extends RigidBody2D

var max_range = 65
var broken_arrow = preload("res://data/scenes/efx/decals/Broken_arrow.tscn")
var group = "projectile"
	

func _physics_process(delta):
	
	if max_range > 0:
		max_range -= 1
	if max_range <= 0:
		self_destroy()
	
	$Arrow.position = lerp($Arrow.position, $Shadow.position, 0.03)


func _on_Area2D_body_entered(body):
	#Spawning decals
	if body is TileMap:
		if body.group == "solid":
			self_destroy()

func self_destroy():
	#Randomized decals
	var fliph = RandomNumberGenerator.new()
	fliph.randomize()
	var flip = fliph.randi_range(0,1)
	
	var spr_index = RandomNumberGenerator.new()
	spr_index.randomize()
	var value = spr_index.randi_range(0,2)
	
	var arrow = broken_arrow.instance()
	
	arrow.position = self.position
	arrow.rotation_degrees = $Shadow.global_rotation_degrees
	arrow.get_node("Sprite").set_frame(spr_index.randi_range(0, 2))
	if flip == 0:
		arrow.get_node("Sprite").flip_v = true
	get_tree().get_root().add_child(arrow)
	queue_free()
