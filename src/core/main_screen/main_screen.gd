extends Control

@onready var user_tab: Control = $Panel/MarginContainer/TabContainer/User

func _ready():
	user_tab.name = Networking.user_info.username
