extends CharacterBody3D


var SPEED = 1.0
const JUMP_VELOCITY = 70
const sensitivity = 0.4
var targetFOV = 60


var direction = Vector3(0, 0, 0)
var input_dir =  0
var friction = 0.7

var vx = 0
var vz = 0
var vy = 0
const walljumpPower = 80
var crouching = false
var onFloorLast =  false

var camrotx = 0
var camroty = 0
var PlayerState = [false,false,false,false,false,false,false]
var targetrot = 0
var justonwall = false

		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event):
	#Mouse movement to head movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(0-event.relative.x * sensitivity))
		if camrotx + (0-event.relative.y * sensitivity) < 80 and camrotx + (0-event.relative.y * sensitivity) > -80:
			camrotx += deg_to_rad(0-event.relative.y * sensitivity)
		if camrotx <-80:
			camrotx = -79
		if camrotx >80:
			camrotx = 79
			
		var skl = $Model/Armature/Skeleton3D
		camrotx = deg_to_rad(clamp(rad_to_deg(camrotx),-100,10))
		

		$Model/Armature/Skeleton3D/BoneAttachment3D.rotate_x((0-(camrotx+90))-$Model/Armature/Skeleton3D/BoneAttachment3D.rotation.x)
		$Camera3D.global_position = $Model/Armature/Skeleton3D/BoneAttachment3D/Cam.global_position
		$Camera3D.global_rotation.x = 0-$Model/Armature/Skeleton3D/BoneAttachment3D/Cam.global_rotation.x

func _physics_process(delta: float) -> void:
	var cam = $Camera3D

	
	
	#Gravity
	if not is_on_floor():
		if velocity.y >= -10:
			vy = -2


	#Mouse in the window
	if Input.is_action_just_pressed("Esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed( 1 ):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	#Sprinting/Speed Control
	if Input.is_action_pressed("Sprint") and is_on_floor() and not crouching:
		PlayerState[1] = true
		SPEED = 2.2
		targetFOV = 120
	else:
		targetFOV = 95
		SPEED = 1.6
	cam.set_fov(cam.fov+((targetFOV-cam.fov)/15))

	#Jumping
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		vy = JUMP_VELOCITY
	else:
		cam.rotation_degrees.z = move_toward(cam.rotation_degrees.z, 0, 1)
	
	
	
	
	#Crouching
	if Input.is_action_pressed("Crouch") and not is_on_wall_only():
		$Collider.scale.y = $Collider.scale.y+((3.2-$Collider.scale.y)/15)
		crouching=true
		PlayerState[2] = true
	else:
		$Collider.scale.y = $Collider.scale.y+((5-$Collider.scale.y)/15)
		crouching=false


	#Taking input and applying it
	input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_wall_only():
		if justonwall:
			print("adding jump")
			justonwall = false
			SPEED=15
			velocity.y += abs(sqrt(velocity.x**2+velocity.z**2))*2
	else:
		
		justonwall = true
	

	#Friction control


	if crouching == true:
		friction = 0.99
	elif is_on_floor() or is_on_wall():
		friction = 0.95
	else:
		friction = 0.96

	#Speed calculations
	if not crouching:
		vx = direction.x * SPEED
		vz = direction.z * SPEED
	else:
		vx = 0
		vz = 0
	velocity.x += vx
	velocity.z += vz
	velocity.y += vy
	
	velocity.x *= friction
	velocity.z *= friction
	
	move_and_slide()
	
	if round(abs(sqrt(velocity.x**2+velocity.z**2))) > 1:
		PlayerState[0] = true
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		PlayerState[3] = true
	
	if velocity.y >0:
		PlayerState[5] = true
	elif velocity.y <=0 and not is_on_floor():
		PlayerState[6] = true
	
	#Jump time is 645
	
	#PLAYERSTATE CODE
	#0 = Walking
	#1 = Sprinting
	#2 = Crouching
	#3 = Strafing
	#4 = OnWall
	#5 = Jumping
	#6 = Falling
	var tree = $Model/AnimationTree
	tree.set("parameters/Blend/blend_amount", 0)
	tree.set("parameters/Blend2/blend_amount", 0)
	tree.set("parameters/TimeScale/scale", 1)
	tree.set("parameters/TimeScale2/scale", 1)
	if PlayerState[0] == true and PlayerState[1] == false and PlayerState[2] == false and PlayerState[3] == false and PlayerState[4] == false and  PlayerState[5] == false and  PlayerState[6] == false:
		tree.set("parameters/Transition/transition_request", "Walking")
		tree.set("parameters/TimeScale/scale", 4.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
	elif  PlayerState[0] == true and PlayerState[1] == true and PlayerState[3] == false and PlayerState[4] == false and  PlayerState[5] == false:
		tree.set("parameters/Transition/transition_request", "Running")
		tree.set("parameters/TimeScale/scale", 1.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
	elif  PlayerState[2] == true:
		tree.set("parameters/Transition/transition_request", "Slide")
	elif PlayerState[3] == true:
		if PlayerState[0] == true:
			tree.set("parameters/Transition2/transition_request", "Walking")
			tree.set("parameters/TimeScale2/scale", 4.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
			tree.set("parameters/Blend/blend_amount", 0.5)
		elif PlayerState[0] == true and PlayerState[1] == true:
			tree.set("parameters/Transition/transition_request", "Running")
			tree.set("parameters/TimeScale/scale", 1.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
			tree.set("parameters/Blend/blend_amount", 0.5)
		if input_dir.x < 0:
			tree.set("parameters/Transition/transition_request", "Left")
		else:
			tree.set("parameters/Transition/transition_request", "Right")
		tree.set("parameters/TimeScale/scale", 9*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
	elif PlayerState[4] == true:
		if not round(get_wall_normal().x) == 0:
			if rotation_degrees.y < 90 and rotation_degrees.y >-90:
				tree.set("parameters/Transition/transition_request", "WallLeft")
			else:

				tree.set("parameters/Transition/transition_request", "WallRight")
		else:
			if rotation_degrees.y < 180 and rotation_degrees.y >0:
				tree.set("parameters/Transition/transition_request", "WallRight")
			else:
				tree.set("parameters/Transition/transition_request", "WallLeft")
		if PlayerState[0] == true and PlayerState[1] == false:
			tree.set("parameters/Transition3/transition_request", "Walking")
			tree.set("parameters/TimeScale3/scale", 4.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
			tree.set("parameters/Blend2/blend_amount", 1)
		elif PlayerState[0] == true and PlayerState[1] == true:
			tree.set("parameters/Transition3/transition_request", "Running")
			tree.set("parameters/TimeScale3/scale", 1.5*(abs(sqrt(velocity.x**2+velocity.z**2))/17))
			tree.set("parameters/Blend2/blend_amount", 1)
	elif PlayerState[5] == true:
		tree.set("parameters/Transition/transition_request", "Jumping")
		tree.set("parameters/TimeScale/scale", 2)
	elif PlayerState[6] == true:
		tree.set("parameters/Transition/transition_request", "Falling")
		tree.set("parameters/TimeScale/scale", 1)
	else:
		tree.set("parameters/Transition/transition_request", "Idle")
	
	PlayerState = [false,false,false,false,false,false,false]
	$%speed.set_text(str(round(abs(sqrt(velocity.x**2+velocity.z**2)))))
	#Engine.time_scale = 0.5
