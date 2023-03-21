extends Panel

@onready var board_node: GridContainer = $HBoxContainer/MainBoardContainer/MarginContainer/CenterContainer/BoardContainer/Board

const board_size: int = 9

var node_board_array: Array = []

func _ready():
	# build board array
	for i in range(0, 9):
		var row: Array = []
		for j in range(0, 9):
			row.push_back()
