extends Control

onready var character = get_parent().get_parent().get_parent()

var state
var text_state
var running = false
var queue = []

#This sets the visibility of everything to 0 when the game starts
func _ready():
	self.modulate.a = 0
	$Title.modulate.a = 0
	$Description.modulate.a = 0
	character.connect("pop_item_ui", self, "item_queue")

#Makes a queue o items
func item_queue(title, description):
	queue.append(title)
	queue.append(description)

#This sets the title and description, sets a timer for the ui to be visible and also
#sets the scroll state to opening.
func next_item():
	$Title.set_text(tr(queue[0]))
	$Description.set_text(tr(queue[1]))
	$End.set_wait_time(3)
	$End.start()
	state = "opening"
	running = true

#Set the state of the scroll to closing, then the scroll closes and gets transparent
func _on_End_timeout():
	state = "closing"

#This one dels with the state machines of text and scroll and also provides animations.
func _physics_process(delta):
	
	if !running and queue.size() > 0:
		next_item()
	
	#This makes the scrolls become transparent or opaque and also open and close
	match state:
		"opening":
			$Scroll.play("open")
			self.modulate.a = lerp(self.modulate.a, 1, .1)
			
			#this detects the frame of the scroll opening animation and then sets a timer and also
			#makes the text become opaque
			if $Scroll.get_frame() == 5:
				text_state = "appear"
				$Text.set_wait_time(2.5)
				$Text.start()
		
		"closing":
			$Scroll.play("close")
			self.modulate.a = lerp(self.modulate.a, 0, .1)
			if self.modulate.a < 0.01 and running:
				queue.remove(1)
				queue.remove(0)
				running = false
	
	#This makes the text become transparent or opaque
	match text_state:
		"appear":
			$Title.modulate.a = lerp($Title.modulate.a, 1, .1)
			$Description.modulate.a = lerp($Description.modulate.a, 1, .2)
			
		"disappear":
			$Title.modulate.a = lerp($Title.modulate.a, 0, .1)
			$Description.modulate.a = lerp($Description.modulate.a, 0, .2)

#Set the text_state to disappear, then the text disappears
func _on_Text_timeout():
	text_state = "disappear"
