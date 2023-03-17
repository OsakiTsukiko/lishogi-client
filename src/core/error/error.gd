extends Control

@onready var error_label: Label = $Panel/CenterContainer/VBoxContainer/Error

func _ready() -> void:
	Networking.connect("specific_error", Callable(self, "do_error"))

func do_error(msg: String) -> void:
	error_label.text = msg
