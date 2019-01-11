extends KinematicBody

var speed = 0
var gravity = -20
var multiplier = 10
var jump = 8
var velocity = Vector3()

func is_near_floor():
	if is_on_floor():
		return true
	var y = get_global_transform().origin.y
	if y < 2 and y > 0:
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
			$"../Control/ProgressBar".value = speed
	if Input.is_action_pressed("ui_down"):
		if speed > 0:
			speed -= 1
			$"../Control/ProgressBar".value = speed

	velocity.x = direction.normalized().x * 5
	velocity.y += gravity * delta
	velocity.z = -(speed * multiplier * delta)
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	if is_on_floor() and Input.is_action_pressed("ui_select"):
		velocity.y = jump

func _process(delta):
	var pos = get_global_transform().origin
	if pos.y < -20:
		get_tree().reload_current_scene()
