extends Window

@onready var token_inp: LineEdit = $Panel/CenterContainer/VBoxContainer/TokenINP
@onready var error_label: Label = $Panel/CenterContainer/VBoxContainer/ErrorLabel
@onready var enter_btn: Button = $Panel/CenterContainer/VBoxContainer/HBoxContainer/EnterBTN

func _ready() -> void:
	Networking.connect("global_error", Callable(self, "do_error"))
	error_label.visible = false

func do_error(msg: String):
	error_label.text = msg
	error_label.visible = true

func _on_close_requested() -> void:
	self.queue_free()

func _on_token_btn_pressed() -> void:
	OS.shell_open("https://lishogi.org/account/oauth/token")

func _on_enter_btn_pressed() -> void:
	enter_btn.disabled = true
	var t: String = token_inp.text
	if (t.replace(" ", "") == "" || t == null):
		do_error("Please enter a valid token!")
		enter_btn.disabled = false
		return
	Networking.check_token(t)
	queue_free()
