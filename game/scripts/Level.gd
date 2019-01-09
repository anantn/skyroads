extends Spatial

var fl = load("res://scenes/Floor.tscn")

var map = [
	[1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0],
	[0, 0, 0, 0, 0],
	[1, 0, 1, 0, 1],
	[0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0],
	[1, 1, 1, 1, 1]
]

func _ready():
	var r = -5
	var c = 2
	for row in map:
		c = 0
		for col in row:
			if col == 1:
				var tile = fl.instance()
				tile.global_translate(Vector3(r, -0.5, c))
				add_child(tile)
			c = c - 2
		r = r + 2
	pass
