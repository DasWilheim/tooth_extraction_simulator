extends Button

@export var forceps_slipped_checkbox : CheckBox 
@export var element_fractured_checkbox : CheckBox 
@export var expoxy_failed_checkbox : CheckBox
@export var non_representative_checkbox : CheckBox
@export var post_extraction_notes_field : TextEdit 

func generate_filename():
	var filename = Time.get_datetime_string_from_system() + "-" + str(Global.selectedQuadrant) +  str(Global.selectedTooth) 
	var i = 0
	for c in filename:
		if c == ':':
			filename[i] = ';'
		i += 1
	return filename
	
func replace_double_dot(string):
		var i = 0
		for c in string:
			if c == ':':
				string[i] = ';'
			i += 1
		return string


# Function to create directory and handle errors
func create_directory(path):
	var dir = DirAccess.open("user://")
	if dir:
		var err = dir.make_dir_recursive(path)
		if err != OK:
			print("Could not create directory: " + path)
			return false
	else:
		print("Could not open base directory: user://")
		return false
	return true

func flatten_vector(vecs):
	var xs = []
	var ys = []
	var zs = []

	for v in vecs:
		xs.append(v.x)
		ys.append(v.y)
		zs.append(v.z)

	return [xs, ys, zs]

func save_extraction_to_file():
	var filename = generate_filename()
	var fl_raw_forces = flatten_vector(Global.raw_forces)
	var fl_raw_torques = flatten_vector(Global.raw_torques)
	var fl_corrected_forces = flatten_vector(Global.corrected_forces)
	var fl_corrected_torques = flatten_vector(Global.corrected_torques)

	# Apply negation to each element in the y and z components of the torques
	var negated_forces_y = fl_raw_forces[2].map(func(x): return -x)
	var negated_torques_y = fl_raw_torques[2].map(func(x): return -x)
	var negated_torques_z = fl_raw_torques[1].map(func(x): return -x)

	var extraction_data = {
		"quadrant": Global.selectedQuadrant,
		"tooth": Global.selectedTooth,
		"jaw_type": Global.selectedType,
		"forceps_slipped": Global.forceps_slipped,
		"element_fractured": Global.element_fractured,
		"epoxy_failed": Global.epoxy_failed,
		"nonrepresentative": Global.non_representative,
		"post_extraction_notes": Global.post_extraction_notes,
		"person_type": Global.loggedInAs,
		"start_timestamp": Global.startTimestamp,
		"end_timestamp": Global.endTimestamp,
		"format_version": 2, # version of the data format

		# Force data split by axis
		"raw_forces_x": fl_raw_forces[0],
		"raw_forces_y": fl_raw_forces[1],
		"raw_forces_z": fl_raw_forces[2],
		"raw_torques_x": fl_raw_torques[0],
		"raw_torques_y": fl_raw_torques[1],
		"raw_torques_z": fl_raw_torques[2],
		"corrected_forces_x": fl_corrected_forces[0],
		"corrected_forces_y": fl_corrected_forces[1],
		"corrected_forces_z": fl_corrected_forces[2],
		"corrected_torques_x": fl_corrected_torques[0],
		"corrected_torques_y": fl_corrected_torques[1],
		"corrected_torques_z": fl_corrected_torques[2]
	}

	Global.extractionDict = extraction_data
	var json_data = JSON.stringify(extraction_data, "\t")

	# Ensure the subfolder structure exists
	var participant_subfolder = "user://" + Global.participantName + "/"

	var folder_subfolder = participant_subfolder + Global.folderName + "/"

	# Create participant and folder subdirectories
	if not create_directory(participant_subfolder):
		return ""
	if not create_directory(folder_subfolder):
		return ""

	# Define the file path
	var filepath = folder_subfolder + "extraction_data_" + filename + ".json"

	# Open the file and store the data
	var save_file = FileAccess.open(filepath, FileAccess.WRITE)
	if save_file:
		save_file.store_line(json_data)
		save_file.close()  # Don't forget to close the file

		# Return the relative path to the saved file
		return Global.participantName + "/" + Global.folderName + "/extraction_data_" + filename + ".json"
	else:
		print("Failed to open file: " + filepath)
		return ""

# Called when the node enters the scene tree for the first time.
func _pressed():
	Global.forceps_slipped = forceps_slipped_checkbox.button_pressed
	Global.element_fractured = element_fractured_checkbox.button_pressed
	Global.epoxy_failed = expoxy_failed_checkbox.button_pressed
	Global.non_representative = non_representative_checkbox.button_pressed
	Global.post_extraction_notes = post_extraction_notes_field.text
	Global.fromExtraction = true

	# Do not store extraction data for demo user
	if Global.loggedInAs != "Demo":
		Global.selectedFile = save_extraction_to_file()

	print("Updating index")
	Global.update_index()
	Global.reset_extraction_data()
	if Global.mode == Global.MODE.automaticExtraction:
		Global.goto_scene("res://scenes/automatic-tooth-selector.tscn")
	else:
		if Global.loggedInAs != "Demo":
			if Global.selectedTooth == 1 and (Global.selectedQuadrant == 1 or Global.selectedQuadrant == 3):
				Global.goto_scene("res://scenes/post-jaw.tscn")
			else:	
				Global.goto_scene("res://scenes/pre-extraction.tscn")
		else:
			Global.goto_scene("res://scenes/dashboard.tscn")
