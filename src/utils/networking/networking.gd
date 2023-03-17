extends Node

@onready var http_cont: Node = $HTTPCont

const token_request_window_scene: Resource = preload("res://src/utils/token_request_window/token_request_window.tscn")
const error_scene: Resource = preload("res://src/core/error/error.tscn")

signal global_error
signal specific_error

const ENDPOINT: String = "https://lishogi.org"
const TOKEN_SAVE_FILE: String = "secret"

var token: String

func _ready() -> void:
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
	var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if (response_code != 200):
		load_token_request_window()
		if (data.has("error")):
			call_deferred("emit_signal", "global_error", data.error)
		return
	Utils.save(TOKEN_SAVE_FILE, token)
	print(data)
