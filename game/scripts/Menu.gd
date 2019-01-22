extends MarginContainer

var lvls = preload("res://scripts/Levels.gd")
var game = load("res://scenes/Main.tscn")

func _ready():
	for i in range(1, len(lvls.LEVELS)):
		var button = Button.new();
		button.text = "Road " + str(i)
		button.set_custom_minimum_size(Vector2(270, 30))
		button.connect("pressed", self, "_load", [i])
		$"VBoxContainer/GridContainer".add_child(button)

func _load(idx):
	Global.ACTIVE_LEVEL = lvls.LEVELS[idx]
	get_tree().change_scene("res://scenes/Main.tscn")
