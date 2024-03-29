extends KinematicBody

const JUMP = 10
const GRAVITY = -40
const SPEED_MULT = 20

var speed = 0
var jumping = false
var velocity = Vector3()
var ex = load("res://scenes/Explosion.tscn")

func is_near_floor():
	if is_on_floor():
		return true
	if get_global_transform().origin.y < 0.5:
		return true
	return false

func _physics_process(delta):
	var direction = Vector3()
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/Menu.tscn")
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		if speed < 100:
			_update_speed(speed+1)
	if Input.is_action_pressed("ui_down"):
		if speed > 0:
			_update_speed(speed-1)
	if Input.is_action_pressed("ui_select") and is_near_floor():
		velocity.y = JUMP
		jumping = true

	velocity.x = direction.normalized().x * 5
	velocity.y += GRAVITY * delta
	velocity.z = -(speed * SPEED_MULT * delta)
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	var count = get_slide_count()
	for i in range(count):
		var collision = get_slide_collision(i)
		if collision.collider.has_meta("burning"):
			_explode()
			return
		var normal = collision.normal.normalized()
		if normal.z > 0.25:
			if collision.collider.has_meta("endcap"):
				_end_game(true)
				break
			if speed < 20:
				_update_speed(0)
				continue
			_explode()
			return
		if normal.y > 0.25:
			if jumping:
				velocity.y += JUMP/2
				jumping = false
			if collision.travel.y > -0.5 and collision.travel.y < -0.01:
				$"Thud".play()

func _process(delta):
	var pos = get_global_transform().origin
	if pos.y < -20:
		$".."._game_over(false)

func _update_speed(value):
	speed = value
	_update_thrust(value)
	$"../Bottom/ProgressBar".value = value

func _update_thrust(value):
	if value == 0:
		$"Left".set_emitting(false)
		$"Right".set_emitting(false)
	else:
		$"Left".set_emitting(true)
		$"Right".set_emitting(true)
		$"Left".process_material.initial_velocity =  value/100.0

func _explode():
	_update_speed(0)
	var e = ex.instance()
	get_parent().add_child(e)
	e.global_translate(get_global_transform().origin)
	e.get_child(0).set_emitting(true)
	e.get_child(1).set_emitting(true)
	e.get_child(2).play()
	_end_game(false)

func _end_game(win):
	var timer = Timer.new()
	timer.connect("timeout", $"..", "_game_over", [win])
	timer.set_wait_time(3)
	timer.set_one_shot(true)
	timer.set_autostart(true)
	get_parent().add_child(timer)
	if win:
		$"../Top/Label".text = "Road Complete!"
	queue_free()
