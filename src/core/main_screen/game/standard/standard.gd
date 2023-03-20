extends Window

@onready var network_clock: Timer = $NetworkClock

var game_btn: Node
var full_id: String
var game_id: String

var http: HTTPClient
var err: int = 0
var headers: PackedStringArray = []

var stage: String = "NONE"

func init(
	game_btn: Node
):
	self.game_btn = game_btn
	self.full_id = game_btn.full_id
	self.game_id = game_btn.game_id

func _ready():
	title = game_btn.opponent_username
	headers.push_back("Authorization: Bearer " + Networking.token)
	
	http = HTTPClient.new()
	err = 0
	
	err = http.connect_to_host(
		Networking.ENDPOINT,
		443
	)
	
	assert(err == OK)
	# i may change this later
	
	stage = "CONNECTING"
	_on_network_clock_timeout()
	network_clock.start()

func _on_network_clock_timeout():
	if (
		stage == "CONNECTING" && 
		(
			http.get_status() == HTTPClient.STATUS_CONNECTING ||
			http.get_status() == HTTPClient.STATUS_RESOLVING
		)
	):
		http.poll()
		print("Connecting...")
	
	elif (stage == "CONNECTING"):
		print(http.get_status())
		assert(http.get_status() == HTTPClient.STATUS_CONNECTED)
		err = http.request(
			HTTPClient.METHOD_GET,
			"/api/board/game/stream/" + game_id,
			headers
		)
		assert(err == OK) 
		stage = "REQUESTING"
	
	if (
		stage == "REQUESTING" && 
		http.get_status() == HTTPClient.STATUS_REQUESTING
	):
		http.poll()
		print("Requesting...")
	
	elif (stage == "REQUESTING"):
		assert(
			http.get_status() == HTTPClient.STATUS_BODY || 
			http.get_status() == HTTPClient.STATUS_CONNECTED
		)
		print("response? ", http.has_response())
		
		if (http.has_response()):
			stage = "RESPONSE_1"
			var h = http.get_response_headers_as_dictionary()
			if (http.get_response_code() != 200):
				network_clock.stop()
				return
			
			if http.is_response_chunked():
				# Does it use chunks?
				# Osaki: I think it should be...
				# Not a http wizard..
				print("Response is Chunked!")
		
	if (stage == "RESPONSE_1"):
		http.poll()
		var chunk = http.read_response_body_chunk()
		print(chunk.get_string_from_ascii())
		# STREAM

func _on_close_requested() -> void:
	self.queue_free()

