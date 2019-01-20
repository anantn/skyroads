extends KinematicBody

const JUMP = 7
const GRAVITY = -20
const SPEED_MULT = 15

var speed = 0
var velocity = Vector3()
var ex = load("res://scenes/Explosion.tscn")

func _physics_process(delta):
	var direction = Vector3()
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		if speed < 100:
			speed += 1
			$"../Control/ProgressBar".value = speed
	if Input.is_action_pressed("ui_down"):
		if speed > 0:
			speed -= 1
			$"../Control/ProgressBar".value = speed
	if Input.is_action_pressed("ui_select") and is_on_floor():
		velocity.y = JUMP

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
			var timer = Timer.new()
			timer.connect("timeout", $"../Level", "_game_over")
			timer.set_wait_time(2.5)
			timer.set_one_shot(true)
			timer.set_autostart(true)
			get_parent().add_child(timer)
			queue_free()

func _process(delta):
	var pos = get_global_transform().origin
	if pos.y < -20:
		$"../Level"._game_over()
