extends PanelContainer

@onready var your_turn_indicator: Label = $MarginContainer/HBoxContainer/YourTurn
@onready var sente_icon: TextureRect = $MarginContainer/HBoxContainer/SenteIcon
@onready var gote_icon: TextureRect = $MarginContainer/HBoxContainer/GoteIcon
@onready var opponent_username_btn: LinkButton = $MarginContainer/HBoxContainer/OpponentUsername
@onready var opponent_rating_label: Label = $MarginContainer/HBoxContainer/OpponentRating
@onready var rated_label: Label = $MarginContainer/HBoxContainer/Rated
@onready var rated_separator: Label = $MarginContainer/HBoxContainer/Separator03
@onready var variant_label: Label = $MarginContainer/HBoxContainer/Variant
@onready var speed_label: Label = $MarginContainer/HBoxContainer/Speed
@onready var time_left_label: Label = $MarginContainer/HBoxContainer/TimeLeft

@onready var time_left_timer: Timer = $TimeLeftTimer

var full_id: String
var game_id: String
var has_moved: bool
var my_turn: bool
var opponent_id # String, but can be null
var opponent_rating: int
var opponent_username: String
var color: String
var rated: bool
var seconds_left: int
var speed: String
var variant_key: String
var variant_name: String
var last_move: String
var sfen: String

func init(
	full_id: String,
	game_id: String,
	has_moved: bool,
	my_turn: bool,
	opponent_id,
	opponent_rating: int,
	opponent_username: String,
	color: String,
	rated: bool,
	seconds_left: int,
	speed: String,
	variant_key: String,
	variant_name: String,
	last_move: String,
	sfen: String
):
	self.full_id = full_id
	self.game_id = game_id
	self.has_moved = has_moved
	self.my_turn = my_turn
	self.opponent_id = opponent_id
	self.opponent_rating = opponent_rating
	self.opponent_username = opponent_username
	self.color = color
	self.rated = rated
	self.seconds_left = seconds_left
	self.speed = speed
	self.variant_key = variant_key
	self.variant_name = variant_name
	self.last_move = last_move
	self.sfen = sfen

func _ready():
	your_turn_indicator.visible = my_turn
	if (color == "sente"):
		sente_icon.visible = true
	if (color == "gote"):
		gote_icon.visible = true
	opponent_username_btn.text = opponent_username
	opponent_rating_label.text = str(opponent_rating)
	rated_label.visible = rated
	rated_separator.visible = rated
	variant_label.text = variant_name
	speed_label.text = speed
	
	time_left_timer.wait_time = seconds_left
	if (has_moved && my_turn):
		time_left_timer.start()

func _process(delta):
	var time_left: int
	if (has_moved && my_turn):
		time_left = (time_left_timer.time_left)
	else:
		time_left = seconds_left
	var tl_string: String = ""
	if (time_left > 3600 * 24):
		var days: int = time_left / (3600 * 24)
		var hours: int = (time_left % (3600 * 24)) / 3600
		tl_string = str(days) + "d"
		if (hours != 0):
			tl_string += " " + str(hours) + "h"
	elif (time_left > 3600):
		var hours: int = time_left / 3600
		var minutes: int = (time_left % 3600) / 60
		tl_string = str(hours) + "h"
		if (minutes != 0):
			tl_string += " " + str(minutes) + "m"
	else:
		var minutes: int = time_left / 60
		var seconds: int = time_left % 60
		tl_string = str(minutes) + "m"
		if (seconds != 0):
			tl_string += " " + str(seconds) + "s"
	
	time_left_label.text = tl_string

func _on_opponent_username_pressed():
	pass

func _on_open_btn_pressed():
	pass
