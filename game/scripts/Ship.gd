extends KinematicBody

var speed = 10
var gravity = -20
var velocity = Vector3()

func _physics_process(delta):
	var direction = Vector3()
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1

	direction = direction.normalized() * speed
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	if is_on_floor() and Input.is_action_just_pressed("ui_select"):
		velocity.y = 10

func _process(delta):
	var pos = get_global_transform().origin
	if pos.y < -20:
		get_tree().reload_current_scene()