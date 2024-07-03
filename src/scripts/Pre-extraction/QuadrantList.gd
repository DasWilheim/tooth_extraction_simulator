extends ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.selectedQuadrant != null:
		if Global.selectedTooth == 1:
			select(Global.selectedQuadrant - 2)
			Global.selectedQuadrant -= 1
		else:
			select(Global.selectedQuadrant - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_selected(index):
	if Global.selectedQuadrant != null:
		if (Global.selectedQuadrant >= 3 and index < 2) or (Global.selectedQuadrant < 3 and index >= 2):
			print("changed upper/lower")
			Global.folderName = "Unkown"
		
		

