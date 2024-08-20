extends Label

func _ready():
	self.text = tr("menu_version") + " " + Global.version
