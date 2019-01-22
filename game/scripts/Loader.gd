extends Spatial

var x = load("res://scenes/Floor.tscn")
var h = load("res://scenes/Half.tscn")
var f = load("res://scenes/Full.tscn")
var t = load("res://scenes/Tunnel.tscn")
var ec = load("res://scenes/EndCap.tscn")
var ht = load("res://scenes/TopTunnel.tscn")
var lvls = preload("res://scripts/Levels.gd")

var materials = {}
var unshaded_materials = {}
func set_color(color, mesh, index, unshaded):
	var mat
	var lookup = materials
	if unshaded:
		lookup = unshaded_materials
	if color in lookup:
		mat = lookup[color]
	else:
		mat = SpatialMaterial.new()
		mat.albedo_color = color
		if unshaded:
			mat.flags_unshaded = true
		else:
			mat.roughness = 0.8
		lookup[color] = mat
	mesh.set_surface_material(index, mat)

var floors = {}
var unshaded_floors = {}
func get_floor(palette, color, unshaded):
	var lookup = floors
	if unshaded:
		lookup = unshaded_floors
	if color in lookup:
		return lookup[color].duplicate()
	var tile = x.instance()
	var mesh = tile.get_child(0)
	var j = 0
	# 0-right, 1-front, 2-left, 3-back, 4-top, 6-bottom
	for i in [4, 1, 0, 2]:
		if unshaded and i == 4:
			set_color(palette[color+j], mesh, i, true)
		else:
			set_color(palette[color+j], mesh, i, false)
		j += 15
	lookup[color] = tile
	return tile.duplicate()

var tops = {}
func get_top(palette, color, type):
	var idx = type+str(color)
	if idx in tops:
		return tops[idx].duplicate()
	var tile
	if type == "h":
		tile = h.instance()
	if type == "f":
		tile = f.instance()
	var mesh = tile.get_child(0)
	var j = 61
	# 0-right, 1-front, 2-left, 3-back, 4-top, 6-bottom
	for i in [4, 1, 0, 2]:
		var setcolor = palette[j]
		if color != 0 and i == 4:
			setcolor = palette[color]
		set_color(setcolor, mesh, i, false)
		j += 1
	tops[idx] = tile
	return tile.duplicate()

var tunnel = null
func get_tunnel(palette):
	if tunnel:
		return tunnel.duplicate()

	var tile = t.instance()
	var mesh = tile.get_child(0)
	var front = palette[66]
	var inside = palette[67]

	# Tunnel order:
	# 0: right-edge (71), 1: right-side (70), 2: top-right (68)
	# 3: top-left (69), 4: left-side (70), 5: left-edge (71)
	# 0-outside, 1-inside, 2-front
	var i = 2
	set_color(palette[68], mesh, i*3+0, false)
	set_color(inside, mesh, i*3+1, false)
	set_color(front, mesh, i*3+2, false)
	i = 3
	set_color(palette[69], mesh, i*3+0, false)
	set_color(inside, mesh, i*3+1, false)
	set_color(front, mesh, i*3+2, false)
	for i in [1, 4]:
		set_color(palette[70], mesh, i*3+0, false)
		set_color(inside, mesh, i*3+1, false)
		set_color(front, mesh, i*3+2, false)
	for i in [0, 5]:
		set_color(palette[71], mesh, i*3+0, false)
		set_color(inside, mesh, i*3+1, false)
		set_color(front, mesh, i*3+2, false)

	tunnel = tile
	return tile.duplicate()

var half_tunnel = null
func get_half_tunnel(palette, color):
	if half_tunnel:
		return half_tunnel.duplicate()
	var tile = ht.instance()
	var mesh = tile.get_child(0)
	var front = palette[66]
	var inside = palette[67]
	# 0: top, 1: front, 2: left, 3: right, 4: back, 5: inside
	var top_color = palette[61]
	if color != 0:
		top_color = palette[color]
	set_color(top_color, mesh, 0, false)
	set_color(palette[62], mesh, 1, false)
	set_color(palette[63], mesh, 3, false)
	set_color(palette[64], mesh, 2, false)
	set_color(palette[65], mesh, 5, false)
	half_tunnel = tile
	return tile.duplicate()

func _ready():
	randomize()
	var level = lvls.LEVELS[randi()%len(lvls.LEVELS)]
	$"../Music".get_child(randi()%$"../Music".get_child_count()).play()

	var r = -5
	for row in level["road"]:
		var c = 0
		var idx = 0
		for col in row:
			if "x" in col[0]:
				var tile = get_floor(level["palette"], col[1], "t" in col[0])
				add_child(tile)
				tile.global_translate(Vector3(r, 0, c))
			if "t" in col[0]:
				if idx == len(row)-1:
					var end = ec.instance()
					add_child(end)
					end.global_translate(Vector3(r, 0, c-3))
				if "f" in col[0]:
					var tile = get_half_tunnel(level["palette"], col[2])
					add_child(tile)
					tile.global_translate(Vector3(r, 0, c))
					var topfill = get_top(level["palette"], col[2], "h")
					add_child(topfill)
					topfill.global_translate(Vector3(r, 1, c))
				elif "h" in col[0]:
					var tile = get_half_tunnel(level["palette"], col[2])
					add_child(tile)
					tile.global_translate(Vector3(r, 0, c))
				else:
					var tile = get_tunnel(level["palette"])
					add_child(tile)
					tile.global_translate(Vector3(r, 0, c))
			else:
				var tile
				if "h" in col[0]:
					tile = get_top(level["palette"], col[2], "h")
				if "f" in col[0]:
					tile = get_top(level["palette"], col[2], "f")
				if tile:
					add_child(tile)
					tile.global_translate(Vector3(r, 0, c))
			c -= 6
			idx += 1
		r += 2

func _game_over():
	get_tree().reload_current_scene()
