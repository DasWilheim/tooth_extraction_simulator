extends Control

@export var list: ItemList
@export var loginButton: Button
@export var participantName: TextEdit

func login():
	if participantName.get_text().length() > 0:
		Global.loggedInAs = list.get_item_text(list.get_selected_items()[0])
		Global.participantName = participantName.get_text()
		print("Loggin in as: ", Global.loggedInAs)
		Global.goto_scene("res://scenes/dashboard.tscn")

func _ready():
	list.select(0)
	loginButton.connect("pressed", login)
