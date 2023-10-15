extends CharacterBody2D

const MAX_RUN_SPEED: float = 300.0
const MAX_WALK_SPEED: float = 100.0
const JUMP_VELOCITY: float = -400.0

const WALK_ANIMATION_NAME: String = "Walk"
const RUN_ANIMATION_NAME: String = "Run"
const IDLE_ANIMATION_NAME: String = "Idle"
const JUMP_ANIMATION_NAME: String = "Jump"

const ROLL_ANIMATION_NAME: String = "Roll"


var animation: String = IDLE_ANIMATION_NAME
var animation_node: AnimatedSprite2D
var speed: float = 0

var is_rolling: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


##
## Init
##

func _ready():
	animation_node = $Animation

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
## Animation
##

# inputs
func animation_process():

	# Si une animation prioritaire est en cours, passer son chemin
	if (is_rolling):
		roll_animation()
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


	animation_node.animation = animation


##
## Physics process
##

# Inputs
func player_movements(_delta):
	if (Input.is_action_just_pressed("roll")):
		roll();

	if (is_rolling):
		return

	velocity.x = 0;
	speed = MAX_WALK_SPEED
	if (Input.is_action_pressed("run")):
		speed = MAX_RUN_SPEED

	if (Input.is_action_pressed("move_right")):
		velocity.x = speed

	if (Input.is_action_pressed("move_left")):
		velocity.x = -speed


# Process
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	player_movements(delta)

	move_and_slide()


func _process(_delta):
	animation_process()


func _on_animation_animation_finished():
	if (is_rolling):
		is_rolling = false

	animation_node.play()


