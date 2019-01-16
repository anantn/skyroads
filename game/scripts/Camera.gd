extends Camera

var zdepth = 0

func diff():
	var cur = get_global_transform().origin
	var pos = $"../Ship".get_global_transform().origin
	return pos.z - cur.z

func _ready():
	zdepth = diff()

func _process(delta):
	var offset = diff()
	if offset != 0:
		global_translate(Vector3(0, 0, offset-zdepth))
