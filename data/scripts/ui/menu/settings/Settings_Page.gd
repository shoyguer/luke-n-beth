extends Control

func _ready():
	Global.connect("changed_language", self, "change_language")

func change_language():
	$Page_1/Settings_language/Language.set_text(tr("settings_language"))
	$Page_1/Settings_display_mode/Display_mode.set_text(tr("settings_display_mode"))
