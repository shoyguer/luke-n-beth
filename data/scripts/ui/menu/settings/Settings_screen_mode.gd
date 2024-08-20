extends OptionButton

func _ready():
	var select
	self.add_item(tr("settings_dm_fullscreen"))
	self.add_item(tr("settings_dm_windowed"))
	match OS.window_fullscreen:
		true:
			select = 0
		false:
			select = 1
	self.select(select)
	Global.connect("changed_language", self, "change_language")

func change_language():
	set_item_text(0, tr("settings_dm_fullscreen"))
	set_item_text(1, tr("settings_dm_windowed"))

func _on_settings_screen_mode_item_selected(index):
	match index:
		0:
			OS.window_fullscreen = true
		1:
			OS.window_fullscreen = false
