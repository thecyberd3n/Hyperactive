extends CharacterBody3D


var SPEED = 1.0
const JUMP_VELOCITY = 18
const sensitivity = 0.4
var targetFOV = 60
var targetRot = 0
var oldRot = 0
var direction = Vector3(0, 0, 0)
var input_dir =  0
var friction = 0.7
var sprintGround = false
var vx = 0
var vz = 0
const walljumpPower = 80
var crouching = false
var onFloorLast =  false

func walljump():
	velocity = get_wall_normal() * walljumpPower
	velocity.y = JUMP_VELOCITY

func stickToWall():
	if is_on_wall_only():
		velocity = Vector3(0-get_wall_normal().x,0-get_wall_normal().y-0.5,0-get_wall_normal().z)*5
		if not round(get_wall_normal().x) == 0:
			if rotation_degrees.y < 90 and rotation_degrees.y >-90:

				$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, 0-(get_wall_normal().x*5), 1)
			else:

				$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, (get_wall_normal().x*5), 1)
		else:
			if rotation_degrees.y < 180 and rotation_degrees.y >0:
				$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, (get_wall_normal().z*5), 1)
			else:
				$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, 0-(get_wall_normal().z*5), 1)

		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.rotation_edit_mode = 2

func _input(event):
	#oldRot = rotation.z
	#rotation.z = 0
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(0-event.relative.x * sensitivity))
		if $Camera3D.rotation_degrees.x + (0-event.relative.y * sensitivity) < 80 and $Camera3D.rotation_degrees.x + (0-event.relative.y * sensitivity) > -80:
			$Camera3D.rotate_x(deg_to_rad(0-event.relative.y * sensitivity))
		if $Camera3D.rotation_degrees.x <-80:
			$Camera3D.rotation_degrees.x = -79
		if $Camera3D.rotation_degrees.x >80:
			$Camera3D.rotation_degrees.x = 79
	#rotation.z = oldRot
	




func _physics_process(delta: float) -> void:

	if not is_on_floor() and not is_on_wall():
		if velocity.y >= -10:
			if crouching:
				velocity.y -= 60 * delta
			else:
				velocity.y -= 60 * delta
	elif is_on_wall():

		if velocity.y >= -10:
			velocity.y -= 5 * delta



	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("Jump") and is_on_wall_only():
		walljump()
	elif is_on_wall_only() and not Input.is_action_just_pressed("Jump"):
		stickToWall()
	else:
		$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, 0, 1)
	if Input.is_action_just_pressed("Esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed( 1 ):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	if Input.is_action_pressed("Sprint") and is_on_floor() and not crouching:
		SPEED = 3
		targetFOV = 120

		$AnimationPlayer.play("Run", -1, round(abs(sqrt(velocity.x**2+velocity.z**2)))/18)
	elif is_on_floor():
		targetFOV = 95
		SPEED = 2.2
		$AnimationPlayer.play("Walk", -1, round(abs(sqrt(velocity.x**2+velocity.z**2)))/7)
	$Camera3D.set_fov($Camera3D.fov+((targetFOV-$Camera3D.fov)/15))
	
	if Input.is_action_pressed("Crouch") and not is_on_wall_only():
		scale.y = scale.y+((4-scale.y)/15)
		crouching=true
	else:
		scale.y = scale.y+((8-scale.y)/15)
		crouching=false



	input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_wall_only():
		if not get_wall_normal().x == 0:
			direction.x = 0
		else:
			direction.z = 0

	if is_on_floor() or is_on_wall():
		friction = 0.85
	elif crouching == true:
		friction = 0.95

	if is_on_floor():
		vx = direction.x * SPEED
		vz = direction.z * SPEED
	else:
		vx = direction.x * SPEED
		vz = direction.z * SPEED
	vx *= 0.80
	vz *= 0.80
	velocity.x += vx
	velocity.z += vz

	velocity.x *= friction
	velocity.z *= friction
	if crouching and not is_on_floor():
		velocity.x += abs(velocity.y)/4 * direction.x
		velocity.z += abs(velocity.y)/4 * direction.z
	$%speed.set_text(str(round(abs(sqrt(velocity.x**2+velocity.z**2)))))
	move_and_slide()
	


	
