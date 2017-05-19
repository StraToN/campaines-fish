extends KinematicBody

# cette version implémente un algorithme de Wander comme proposé par Craig W. Reynolds
# http://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-wander--gamedev-1624

# The basic idea is to produce small random displacements and apply to the character's 
# current direction vector (the velocity, in our case) every game frame. 
# Since the velocity vector defines where the character is heading to and how much it 
# moves every frame, any interference with that vector will change the current route.


# The displacement force  has its origin at the circle's center, and is constrained by the circle radius. 
# The greater the radius and the distance from character to the circle, the stronger the "push" the 
# character will receive every game frame.


# IDEE
# selon la couleur, les poissons vont plus ou moins vite.

const DISPLACEMENT_MAX_RADIUS = 50.0
const DISPLACEMENT_DISTANCE = 0.01
const MAX_VELOCITY = 0.01
const SMOOTH_SPEED = 0.01
const MAX_FORCE = 2.0

var displacementCenter
var displacementForce
var ANGLE_CHANGE = PI/20
var wanderAngle
var steering
var velocity

## DEBUG
var DEBUG = false
var debugVectorsBeginPos

var width = 772
var height = 1027

var justRespawned = false


func _ready():
	randomize()
	
	velocity = Vector3( 0, 0, MAX_VELOCITY)
	debugVectorsBeginPos = Vector3(0, 0, 65) # only for display
	wanderAngle = clamp(rand_range(-2*PI, 2*PI),-PI, PI)
	displacementCenter = Vector3(0,0,0)
	displacementForce = Vector3(0,0,0)

	set_fixed_process(true)
	pass



func _fixed_process(delta):
	## MOVEMENT
	if (justRespawned):
		steering = seek(Vector3(width/2, 0, height/2), delta)
	else:
		steering = wander()
		steering = truncate(steering, MAX_FORCE)
		steering = steering / 1.0 #mass
		velocity = truncate(velocity + steering, MAX_VELOCITY)
		move(velocity)

#	var globPos = get_global_pos()
#	if (not is_out_of_screen(globPos)):
#		print(get_global_pos())
#	if (globPos.x - width/2 < 1.0 && globPos.y - height/2 < 1.0):
#		justRespawned = false

#	# respawn if out of screen
#	if ( is_out_of_screen(globPos) and justRespawned == false ):
#		print("RESPAWN")
#		set_global_pos(get_parent().get_node("respawn_point").get_pos())
#		look_at( Vector3(width/2, height/2), 0)	 # look at center of screen
#		justRespawned = true
	
	## ROTATION
#	var ang = get_angle_to(get_pos()+ velocity.normalized())
#	rotate( ang*delta*SMOOTH_SPEED )



func wander():
	# calculate center of displacement circle
	displacementCenter = Vector3(0, 0, 1) * DISPLACEMENT_DISTANCE
	displacementForce = Vector3(0, 0, 1) * DISPLACEMENT_MAX_RADIUS
	
	# Randomly change the vector direction by making it change its current angle
	var len = displacementForce.length()
	displacementForce.x = cos(wanderAngle) * len
	displacementForce.z = sin(wanderAngle) * len
	
	# Change wanderAngle just a bit, so it won't have the same value in the next game frame.
	wanderAngle += clamp(rand_range(-ANGLE_CHANGE, ANGLE_CHANGE),-PI, PI)
	
	var wanderForce = displacementCenter + displacementForce

	return wanderForce


func is_close_to_wall(pos):
	var distanceMax = 50
	if (pos.x <= distanceMax or pos.x >= width-distanceMax or pos.z <= distanceMax or pos.z >= height-distanceMax):
		return true
	else:
		return false

func is_out_of_screen(pos):
	if (pos.x < -50 or pos.x > width + 50 or pos.z < -50 or pos.z > height + 50):
		return true
	else:
		return false

func truncate(vector, len):
	if (vector.length() > len):
		vector = vector.normalized()
		vector *= len
	return vector


func seek(targetPos, delta):
	look_at(targetPos)
	var velocity = (targetPos - get_pos()).normalized() * MAX_VELOCITY
	var nextPosition = get_pos() + velocity
	set_pos(nextPosition)
