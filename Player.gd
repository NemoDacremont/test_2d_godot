extends CharacterBody2D

const MAX_RUN_SPEED: float = 300.0
const MAX_WALK_SPEED: float = 100.0
const JUMP_VELOCITY: float = -400.0

const WALK_ANIMATION_NAME: String = "Walk"
const RUN_ANIMATION_NAME: String = "Run"
const IDLE_ANIMATION_NAME: String = "Idle"

const WALL_SLIDING_ANIMATION_NAME: String = "WallSlide"

const JUMP_ANIMATION_NAME: String = "Jump"
const JUMP_ASCENDING_ANIMATION_FRAME = 0
const JUMP_INERTIA_ANIMATION_FRAME = 1
const JUMP_FALLILNG_ANIMATION_FRAME = 2
const JUMP_EPSILON_VELOCITY_THRESHOLD = 100

const ROLL_ANIMATION_NAME: String = "Roll"
const ROLL_REST_DURATION: float = 0.2


var speed: float = 0

var animation: String = IDLE_ANIMATION_NAME
var animation_node: AnimatedSprite2D
var wall_sliding_timer: Timer
var roll_rest_timer: Timer

var is_rolling: bool = false
var is_jumping: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


##
## Init
##

func _ready():
	animation_node = $Animation
	wall_sliding_timer = $Wall_Sliding_Timer
	roll_rest_timer = $Roll_Rest_Timer

	show()


##
##  Roll
##

func roll():
	print("start rolling")
	is_rolling = true


func roll_animation():
	if (Input.is_action_just_pressed("roll")):
		animation_node.play(ROLL_ANIMATION_NAME)


##
## Jump
##

func jump():
	is_jumping = true


func jump_animation():
	animation_node.play(JUMP_ANIMATION_NAME)
	print(velocity.y)
	if (is_jumping && abs(velocity.y) < JUMP_EPSILON_VELOCITY_THRESHOLD):
		# animation_node.animation = JUMP_ANIMATION_NAME
		animation_node.frame = JUMP_ASCENDING_ANIMATION_FRAME
		return

	if (is_jumping && velocity.y > 0):
		# animation_node.animation = JUMP_ANIMATION_NAME
		animation_node.frame = JUMP_ASCENDING_ANIMATION_FRAME
		return

##
## Animation
##

# inputs
func animation_process():

	# Si une animation prioritaire est en cours, passer son chemin
	if (is_rolling):
		roll_animation()
		return

	## Orientation
	if (Input.is_action_pressed("move_right")):
		animation_node.flip_h = false
	
	if (Input.is_action_pressed("move_left")):
		animation_node.flip_h = true
		
	if (is_on_wall_only()):
		animation_node.play(WALL_SLIDING_ANIMATION_NAME)
		return

	# Falling sprite
	if (velocity.y > 0):
		animation_node.play(JUMP_ANIMATION_NAME)
		animation_node.frame = JUMP_FALLILNG_ANIMATION_FRAME

		return

	## Jumping, priority animation
	if (is_jumping):
		jump_animation()
		return


	animation = IDLE_ANIMATION_NAME

	if (Input.is_action_pressed("move_right")):
		animation = WALK_ANIMATION_NAME
		animation_node.flip_h = false
	
	if (Input.is_action_pressed("move_left")):
		animation = WALK_ANIMATION_NAME
		animation_node.flip_h = true

	if (Input.is_action_pressed("run") and velocity.x != 0):
		animation = RUN_ANIMATION_NAME


	animation_node.play(animation)


##
## Physics process
##

# Inputs
func player_movements(_delta):
	if (Input.is_action_just_pressed("roll") and roll_rest_timer.is_stopped()):
		roll();

	if (is_rolling):
		return

	# walk speed :)
	velocity.x = 0;
	speed = MAX_WALK_SPEED

	# Handle Running
	if (Input.is_action_pressed("run")):
		speed = MAX_RUN_SPEED


	## Handle Jump.
	if (is_jumping and (is_on_floor() or is_on_wall())):
		is_jumping = false

	# Turns enabled while jumping, stop handling run if jumping

	# Set direction
	if (Input.is_action_pressed("move_right")):
		velocity.x = speed

	if (Input.is_action_pressed("move_left")):
		velocity.x = -speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = JUMP_VELOCITY
		velocity.x = - speed

		is_jumping = true


# Process
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	player_movements(delta)

	move_and_slide()


func _process(_delta):
	animation_process()


func _on_animation_animation_finished():
	if (is_rolling):
		is_rolling = false
		roll_rest_timer.start(ROLL_REST_DURATION)


	animation_node.play()


