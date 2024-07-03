extends Button

@export var expoxy_failed_checkbox: CheckBox
@export var non_representative_checkbox: CheckBox
@export var post_extraction_notes_field: TextEdit


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

func save_metadata_to_file():

	var metadata = {
		"epoxy_failed": Global.epoxy_failed,
		"non_representative": Global.non_representative,
		"post_extraction_notes": Global.post_extraction_notes
	}

	var json_data = JSON.stringify(metadata, "\t")

	# Ensure the subfolder structure exists
	var participant_subfolder = "user://" + Global.participantName + "/"
	var folder_subfolder = participant_subfolder + Global.folderName + "/"

	# Create participant and folder subdirectories
	if not create_directory(participant_subfolder):
		return ""
	if not create_directory(folder_subfolder):
		return ""

	# Define the file path
	var filepath = folder_subfolder + "metadata.json"

	# Open the file and store the data
	var save_file = FileAccess.open(filepath, FileAccess.WRITE)
	if save_file:
		save_file.store_line(json_data)
		save_file.close()  # Don't forget to close the file

		# Return the relative path to the saved file
		return Global.participantName + "/" + Global.folderName + "/metadata.json"
	else:
		print("Failed to open file: " + filepath)
		return ""

# Called when the node enters the scene tree for the first time.
func _pressed():
	Global.epoxy_failed = expoxy_failed_checkbox.button_pressed
	Global.non_representative = non_representative_checkbox.button_pressed
	Global.post_extraction_notes = post_extraction_notes_field.text

	# Do not store metadata for demo user
	if Global.loggedInAs != "Demo":
		save_metadata_to_file()

	print("Updating index")
	Global.update_index()
	Global.reset_extraction_data()
	Global.folderName = "Unkown"
	Global.goto_scene("res://scenes/pre-extraction.tscn")
