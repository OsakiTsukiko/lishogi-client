extends PanelContainer

func _process(delta):
	var board_size: float = min(
		get_parent().size.x,
		get_parent().size.y
	)
