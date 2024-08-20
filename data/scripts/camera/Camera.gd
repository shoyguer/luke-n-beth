extends Camera2D

func _process(delta):
	if self.current == true and self.zoom != Vector2(1,1):
		self.zoom = lerp(self.zoom, Vector2(1,1), .05)
	if self.current == true and self.position != Vector2(0,0):
		self.position = lerp(self.position, Vector2(0,0), .05)
