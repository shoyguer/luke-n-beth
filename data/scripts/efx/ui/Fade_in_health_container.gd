extends Control

func _ready():
	#Set the current frame of FadeIn to 0 because it is an oneshot
	$Fade_in.texture.set_current_frame(0)
	#Set the end of the animation
	$Fade_in/End.rect_position.x = $Fade_in.rect_position.x + $Fade_in.rect_size.x
	$Fade_in/End.texture.set_current_frame(0)
	#Set the current frame of FadeOut to 0 because it is an oneshot
	$Fade_out.texture.set_current_frame(0)
	#Set the end of the animation
	$Fade_out/End.rect_position.x = $Fade_out.rect_position.x + $Fade_out.rect_size.x
	$Fade_out/End.texture.set_current_frame(0)


func _physics_process(delta):
	#Destroy the node when the animation is ended
	if $Fade_in.texture.get_current_frame() == 5:
		self.queue_free()
	#Destroy the node when the animation is ended
	if $Fade_out.texture.get_current_frame() == 5:
		self.queue_free()
