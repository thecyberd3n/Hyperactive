extends CharacterBody3D


var SPEED = 1.0
const JUMP_VELOCITY = 12
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

func facingNorth():
	if 90 > rotation_degrees.y and rotation_degrees.y > -90:
		return true
	else:
		return false

func facingWest():
	if 0 < rotation_degrees.y and rotation_degrees.y < 180:
		return true
	else:
		return false

func isWallRight():
	if is_on_wall():
		if not get_wall_normal().x == 0:
			if facingNorth():
				if get_wall_normal().x == -1:
					return true
				else:
					return false
			else:
				if get_wall_normal().x == 1:
					return true
				else:
					return false
		elif not get_wall_normal().z == 0:
			if facingWest():
				if get_wall_normal().z == 1:
					return true
				else:
					return false
			else:
				if get_wall_normal().z == -1:
					return true
				else:
					return false

func walljump():
	velocity.y = 23*($Camera3D.rotation_degrees.x+50)/60
	if not get_wall_normal().x == 0:
		if facingNorth():
			if isWallRight():
				velocity.x = -walljumpPower
			else:
				velocity.x = walljumpPower
		else:
			if isWallRight():
				velocity.x = walljumpPower
			else:
				velocity.x = -walljumpPower
	else:
		if facingWest():
			if isWallRight():
				velocity.z = walljumpPower
			else:
				velocity.z = -walljumpPower
		else:
			if isWallRight():
				velocity.z = -walljumpPower
			else:
				velocity.z = walljumpPower
func stickToWall():
	if not get_wall_normal().x == 0:
		if facingNorth():
			if isWallRight():
				velocity.x = 10
			else:
				velocity.x = -10
		else:
			if isWallRight():
				velocity.x = -10
			else:
				velocity.x = 10
	else:
		if facingWest():
			if isWallRight():
				velocity.z = -10
			else:
				velocity.z = 10
		else:
			if isWallRight():
				velocity.z = 10
			else:
				velocity.z = -10

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

	if not is_on_floor() and not is_on_wall():
		if velocity.y >= -10:
			velocity.y -= 30 * delta
	elif is_on_wall():
		if velocity.y> 0:
			velocity.y = 0
		if velocity.y >= -10:
			velocity.y -= 5 * delta

	if is_on_wall_only():
		if isWallRight():
			$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, 5, 1)
		else:
			$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, -5, 1)
	else:
		$Camera3D.rotation_degrees.z = move_toward($Camera3D.rotation_degrees.z, 0, 1)

	print($Camera3D.rotation_degrees.x)

	if Input.is_action_just_pressed("Dash"):
		print("Dash")
		velocity =+ (transform.basis * Vector3(0, 0, -1)).normalized()*300
		velocity.y =+ ($Camera3D.rotation_degrees.x/180)*50
		
		move_and_slide()
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("Jump") and is_on_wall_only():
		walljump()
	elif is_on_wall_only() and not Input.is_action_just_pressed("Jump"):
		stickToWall()

	if Input.is_action_just_pressed("Esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed( 1 ):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	if Input.is_action_pressed("Sprint") and is_on_floor() and not crouching:
		SPEED = 3
		targetFOV = 120
	elif is_on_floor():
		targetFOV = 95
		SPEED = 2.2
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
	$%speed.set_text(str(round(abs(sqrt(velocity.x**2+velocity.z**2)))))
	move_and_slide()
	
