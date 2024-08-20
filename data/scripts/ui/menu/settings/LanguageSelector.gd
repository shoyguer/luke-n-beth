extends OptionButton

func _ready():
	var select
	self.add_item("English")
	self.add_item("Português")
	match Global.language:
		"en":
			select = 0
		"pt":
			select = 1
	self.select(select)

func _on_LanguageSelector_item_selected(index):
	match index:
		0:
			Global.change_language("en")
		1:
			Global.change_language("pt")
