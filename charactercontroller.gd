extends CharacterBody3D




var SPEED = 10.0
const JUMP_VELOCITY = 12
const sensitivity = 0.4
var targetFOV = 60
var targetRot = 0
var oldRot = 0
var direction = 0
var input_dir =  0
var friction = 0.7
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.rotation_edit_mode = 2

func _input(event):
	oldRot = rotation.z
	rotation.z = 0
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(0-event.relative.x * sensitivity))
		if $Camera3D.rotation_degrees.x + (0-event.relative.y * sensitivity) < 80 and $Camera3D.rotation_degrees.x + (0-event.relative.y * sensitivity) > -80:
			$Camera3D.rotate_x(deg_to_rad(0-event.relative.y * sensitivity))
		if $Camera3D.rotation_degrees.x <-80:
			$Camera3D.rotation_degrees.x = -79
		if $Camera3D.rotation_degrees.x >80:
			$Camera3D.rotation_degrees.x = 79
	rotation.z = oldRot
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_on_wall():
		if velocity.y >= -10:
			velocity.y -= 35 * delta

	SPEED = 10.0
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or is_on_wall_only()):
		velocity.y = JUMP_VELOCITY
		print(get_wall_normal().x)
		print((1 * int(rotation_degrees.y > 0)))
		print(rotation_degrees.y)
		if (1 * int(rotation_degrees.y > 0)):
			print("left")
		else:
			print("right")
		if get_wall_normal().x == (1 * int(rotation_degrees.y+180 > 0)):
			print("+5")
			SPEED = 20.0
			direction = (transform.basis * Vector3(5, 0, -2)).normalized()
		elif get_wall_normal().x == (1 * int(rotation_degrees.y+180 > 0)):
			print("+5")
			SPEED = 20.0
			direction = (transform.basis * Vector3(5, 0, -2)).normalized()

	if Input.is_action_just_pressed("Esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("Sprint"):
		SPEED = 20.0
		targetFOV = 120
	else:
		targetFOV = 95
	$Camera3D.set_fov($Camera3D.fov+((targetFOV-$Camera3D.fov)/15))

	if Input.is_mouse_button_pressed( 1 ):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	targetRot = 0

	#if Input.is_action_pressed("Forward"):

		
	if rotation_degrees.z > 10:
		$Camera3D.rotation_degrees.z = 10
	elif rotation_degrees.z < -10:
		$Camera3D.rotation_degrees.z = -10
	$Camera3D.rotate_z(deg_to_rad(((targetRot-$Camera3D.rotation_degrees.z)/10)))
	if $Camera3D.rotation_degrees.z < 1 and $Camera3D.rotation_degrees.z > -1:
		$Camera3D.rotation_degrees.z = 0

	if get_wall_normal().x == 0:
		input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor() or is_on_wall():
		friction = 0.9
	else:
		friction = 0.3
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)

	move_and_slide()
