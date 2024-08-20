extends AnimatedSprite

func _physics_process(delta):
	
	if rotation_degrees >= 360:
		rotation_degrees = 0
	elif rotation_degrees <= 0:
		rotation_degrees += 360
