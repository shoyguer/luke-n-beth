extends Node

var version = "0.00.75 pre-alpha"

var language = "en" setget change_language

signal changed_language

func change_language(value):
	language = value
	TranslationServer.set_locale(language)
	emit_signal("changed_language")

func _ready():
	TranslationServer.set_locale(language)
