extends Camera

var zdepth = 0
var lastpos = Vector3()

func diff():
	var cur = get_global_transform().origin
	if get_parent().has_node("Ship"):
		lastpos = $"../Ship".get_global_transform().origin
	return lastpos.z - cur.z

func _ready():
	zdepth = diff()

func _process(delta):
	var offset = diff()
	if offset != 0:
		global_translate(Vector3(0, 0, offset-zdepth))
