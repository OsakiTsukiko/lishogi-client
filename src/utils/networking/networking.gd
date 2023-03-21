extends Node

@onready var http_cont: Node = $HTTPCont
@onready var games_cont: Node = $GamesCont

const token_request_window_scene: Resource = preload("res://src/utils/token_request_window/token_request_window.tscn")
const error_scene: Resource = preload("res://src/core/error/error.tscn")
const main_screen: Resource = preload("res://src/core/main_screen/main_screen.tscn")

const standard_game_scene: Resource = preload("res://src/core/main_screen/game/standard/standard.tscn")

signal global_error
signal specific_error

const ENDPOINT: String = "https://lishogi.org"
const TOKEN_SAVE_FILE: String = "secret"

var token: String
var user_info: Dictionary
var user_preferences: Dictionary

var is_debug: bool = OS.is_debug_build()

var opened_games: Array[Node] = []

func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2(1152, 648))
	make_http_req(
		ENDPOINT,
		PackedStringArray([]),
		HTTPClient.METHOD_GET,
		{},
		Callable(self, "_check_internet_connection")
	)

func make_http_req(
	url: String,
	headers: PackedStringArray,
	method: int,
	req_body: Dictionary,
	callback: Callable
) -> void:
	var http_req_node: HTTPRequest = HTTPRequest.new()
	http_req_node.use_threads = true
	http_cont.add_child(http_req_node)
	http_req_node.connect("request_completed", callback)
	http_req_node.connect("request_completed", Callable(self, "_free_http_req").bind(http_req_node))
	http_req_node.request(
		url,
		headers,
		method,
		JSON.stringify(req_body)
	)

func load_token_request_window() -> void:
	var trw: Window = token_request_window_scene.instantiate()
	trw.visible = false
	add_child(trw)
	trw.popup_centered()

func check_token(t: String) -> void:
	token = t
	make_http_req(
		ENDPOINT + "/api/account",
		PackedStringArray(["Authorization: Bearer " + t]),
		HTTPClient.METHOD_GET,
		{},
		Callable(self, "_check_token")
	)

func _free_http_req(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, node: HTTPRequest) -> void:
	node.queue_free()

func _check_internet_connection(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if (response_code == 200):
		# check for saved token
		var t = Utils.load_save(TOKEN_SAVE_FILE)
		if (t != null):
			if (typeof(t) == typeof(token)): # unnecessary check?
				check_token(t)
			else:
				load_token_request_window()
		else:
			load_token_request_window()
	else:
		get_tree().change_scene_to_packed(error_scene)
		call_deferred("emit_signal", "specific_error", "Unable to reach " + ENDPOINT)

func _check_token(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if (response_code != 200):
		var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		load_token_request_window()
		if (data.has("error")):
			call_deferred("emit_signal", "global_error", data.error)
		return
	var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	Utils.save(TOKEN_SAVE_FILE, token)
	user_info = data
	load_profile()
	make_http_req(
		ENDPOINT + "/api/account/preferences",
		PackedStringArray(["Authorization: Bearer " + token]),
		HTTPClient.METHOD_GET,
		{},
		Callable(self, "_get_user_preferences")
	)

func _get_user_preferences(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if (response_code == 200):
		var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		user_preferences = data
		load_profile()

func load_profile() -> void:
	if (
		user_info == {} || 
		user_info == null || 
		user_preferences == {} ||
		user_preferences == null
	): 
		return
	get_tree().change_scene_to_packed(main_screen)
	if (is_debug):
		Utils.save_debug("user_info", user_info)
		Utils.save_debug("user_preferences", user_preferences)

func open_game(game_btn: Node):
	for game in opened_games:
		if (game.full_id == game_btn.full_id):
			game.grab_focus()
			return
	
	if (game_btn.variant_key == "standard"):
		var game: Node = standard_game_scene.instantiate()
		game.init(game_btn)
		games_cont.add_child(game)
		opened_games.push_back(game)
