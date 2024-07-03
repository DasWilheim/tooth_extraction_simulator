extends Button

func replace_double_dot(string):
		var i = 0
		for c in string:
			if c == ':':
				string[i] = ';'
			i += 1
		return string

# Called when the node enters the scene tree for the first time.
func _pressed():
	if Global.is_pre_extraction_data_valid():
		if Global.folderName == "Unkown":
			if Global.selectedQuadrant > 2:
				Global.folderName = replace_double_dot("lower_" + Time.get_datetime_string_from_system())
			else:
				Global.folderName = replace_double_dot("upper_" + Time.get_datetime_string_from_system())
		Global.goto_scene("res://scenes/extraction.tscn")
	else:
		OS.alert("Please select the quadrant, tooth and type")
		
