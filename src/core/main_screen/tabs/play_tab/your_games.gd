extends Panel

@onready var games_cont: VBoxContainer = $MarginContainer/ScrollContainer/GamesCont

var game_node_scene: Resource = load("res://src/core/main_screen/tabs/play_tab/game.tscn")

func _ready():
	Networking.make_http_req(
		Networking.ENDPOINT + "/api/account/playing",
		PackedStringArray(["Authorization: Bearer " + Networking.token]),
		HTTPClient.METHOD_GET,
		{},
		Callable(self, "_get_my_ongoing_games")
	)

func _on_timer_timeout():
	Networking.make_http_req(
		Networking.ENDPOINT + "/api/account/playing",
		PackedStringArray(["Authorization: Bearer " + Networking.token]),
		HTTPClient.METHOD_GET,
		{},
		Callable(self, "_get_my_ongoing_games")
	)

func _get_my_ongoing_games(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if (response_code == 200):
		var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		
		if (Networking.is_debug):
			Utils.save_debug("my_ongoing_games", data)
		
		for index in range(0, data.nowPlaying.size()):
			var game: Dictionary = data.nowPlaying[index]
			var game_node: Node = game_node_scene.instantiate()
			
			var opponent_rating: int = 0
			if (game.opponent.has("rating")):
				opponent_rating = game.opponent.rating
			
			game_node.init(
				game.fullId,
				game.gameId,
				game.hasMoved,
				game.isMyTurn,
				game.opponent.id,
				opponent_rating,
				game.opponent.username,
				game.color,
				game.rated,
				game.secondsLeft,
				game.speed,
				game.variant.key,
				game.variant.name,
				game.lastMove,
				game.sfen
			)
			
			for old_game in games_cont.get_children():
				if (old_game.full_id == game.fullId):
					old_game.queue_free()
			
			games_cont.add_child(game_node)
			games_cont.move_child(game_node, index)
