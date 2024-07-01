extends ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	# Call the custom function to handle the initial tooth selection
	_on_ready()

# Custom function to handle the initial selection logic
func _on_ready():

	if Global.selectedTooth != null:
		var new_index = max(Global.selectedTooth - 2, 0) # Ensure index is not negative
		if Global.selectedTooth > 1:
			Global.selectedTooth = Global.selectedTooth -1
		else:
			Global.selectedTooth = 8
			new_index = 7
		select(new_index)
