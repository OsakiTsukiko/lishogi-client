extends Node
class_name Utils

static func save(file_name: String, data) -> void:
	var file := FileAccess.open("user://" + file_name + ".save", FileAccess.WRITE)
	file.store_buffer(var_to_bytes(data))
	file.close()

static func load_save(file_name: String):
	if (FileAccess.file_exists("user://" + file_name + ".save")):
		var file := FileAccess.open("user://" + file_name + ".save", FileAccess.READ)
		var data = bytes_to_var(file.get_buffer(file.get_length()))
		file.close()
		return data
	return null

static func save_debug(file_name: String, data) -> void:
	var file := FileAccess.open("user://" + file_name + ".debug", FileAccess.WRITE)
	file.store_string(var_to_str(data))
	file.close()
