extends KinematicBody

const JUMP = 12
const GRAVITY = -40
const SPEED_MULT = 20

const JUMP_NO = 0
const JUMP_NOW = 1
const JUMP_BOUNCE = 2

var speed = 0
var jumping = JUMP_NO
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
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		if speed < 100:
			speed += 1
			_update_thrust(speed)
			$"../Control/ProgressBar".value = speed
	if Input.is_action_pressed("ui_down"):
		if speed > 0:
			speed -= 1
			_update_thrust(speed)
			$"../Control/ProgressBar".value = speed
	if Input.is_action_pressed("ui_select") and is_near_floor():
		velocity.y = JUMP
		jumping = JUMP_NOW

	velocity.x = direction.normalized().x * 5
	velocity.y += GRAVITY * delta
	velocity.z = -(speed * SPEED_MULT * delta)
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	var count = get_slide_count()
	for i in range(count):
		var collision = get_slide_collision(i)
		if collision.normal.z > 0.05:
			var e = ex.instance()
			get_parent().add_child(e)
			e.global_translate(get_global_transform().origin)
			e.get_child(0).set_emitting(true)
			e.get_child(1).set_emitting(true)
			e.get_child(2).play()
			var timer = Timer.new()
			timer.connect("timeout", $"../Level", "_game_over")
			timer.set_wait_time(3)
			timer.set_one_shot(true)
			timer.set_autostart(true)
			get_parent().add_child(timer)
			queue_free()
		if collision.normal.y > 0.05:
			if jumping == JUMP_NOW:
				velocity.y += JUMP/2
				jumping = JUMP_BOUNCE
			elif jumping == JUMP_BOUNCE:
				jumping = JUMP_NO

func _process(delta):
	var pos = get_global_transform().origin
	if pos.y < -20:
		$"../Level"._game_over()

func _update_thrust(speed):
	if speed == 0:
		$"Left".set_emitting(false)
		$"Right".set_emitting(false)
	else:
		$"Left".set_emitting(true)
		$"Right".set_emitting(true)
		$"Left".process_material.initial_velocity =  speed/100.0