extends KinematicBody2D

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
const DISPLACEMENT_DISTANCE = 2.0
const MAX_VELOCITY = {"green":0.75, "pink":1.0, "blue":1.5, "yellow":2.0}
const SMOOTH_SPEED = 2.0
const MAX_FORCE = 5.0

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


export(String) var color setget set_color,get_color

func _ready():
	randomize()
	
	get_node("head").set_texture( load("res://assets/"+ color + "/fish_1.tex") )
	get_node("head/s1").set_texture( load("res://assets/"+ color + "/fish_2.tex") )
	get_node("head/s1/s2").set_texture( load("res://assets/"+ color + "/fish_3.tex") )
	get_node("head/s1/s2/s3").set_texture( load("res://assets/"+ color + "/fish_4.tex") )
	get_node("head/s1/s2/s3/s4").set_texture( load("res://assets/"+ color + "/fish_5.tex") )
	get_node("head/s1/s2/s3/s4/s5").set_texture( load("res://assets/"+ color + "/fish_6.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6").set_texture( load("res://assets/"+ color + "/fish_7.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6/s7").set_texture( load("res://assets/"+ color + "/fish_8.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6/s7/s8").set_texture( load("res://assets/"+ color + "/fish_9.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6/s7/s8/s9").set_texture( load("res://assets/"+ color + "/fish_10.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6/s7/s8/s9/s10").set_texture( load("res://assets/"+ color + "/fish_11.tex") )
	get_node("head/s1/s2/s3/s4/s5/s6/s7/s8/s9/s10/s11").set_texture( load("res://assets/"+ color + "/fish_12.tex") )
	
	velocity = Vector2( 0, MAX_VELOCITY[color])
	debugVectorsBeginPos = Vector2(0, 65) # only for display
	wanderAngle = clamp(rand_range(-2*PI, 2*PI),-PI, PI)
	displacementCenter = Vector2(0,0)
	displacementForce = Vector2(0,0)
	
	var scale = rand_range( 0.3, 0.7)
	set_scale( Vector2(scale, scale) )
	
	var animSpeed = 2.0
	if (scale <= 0.5):
		animSpeed /= 1.5
	
	## ANIM
	#if (not get_node("bluefish/AnimationPlayer").is_playing()):
	get_node("AnimationPlayer").play("swim")
	get_node("AnimationPlayer").set_speed(animSpeed)

	set_fixed_process(true)
	pass


func _draw():
	if DEBUG:
		# Displacement Circle
		draw_circle( debugVectorsBeginPos + displacementCenter, DISPLACEMENT_MAX_RADIUS, Color(0.7,0.7,0.7))
		
		# Displacement Force
		draw_line( debugVectorsBeginPos + displacementCenter, debugVectorsBeginPos + displacementCenter + displacementForce, Color(1,0,0), 2)
		
		# Front
		draw_line( debugVectorsBeginPos, (debugVectorsBeginPos - velocity) * 2, Color(0,1,0), 2)
		
		# Wander Force
		draw_line( Vector2(0,0), debugVectorsBeginPos + displacementCenter + displacementForce, Color(1,1,0), 2)
		
		# Velocity
		draw_line( debugVectorsBeginPos, (debugVectorsBeginPos - velocity) + (debugVectorsBeginPos + displacementCenter + displacementForce) , Color(0,1,1), 2)
	

func _fixed_process(delta):
	## MOVEMENT
	if (justRespawned):
		steering = seek(Vector2(width/2, height/2), delta)
	else:
		steering = wander()
		steering = truncate(steering, MAX_FORCE)
		steering = steering / 1.0 #mass
		velocity = truncate(velocity + steering, MAX_VELOCITY[color])
		set_pos(get_pos() + velocity)

	var globPos = get_node("head/s1/s2/s3/s4/s5/s6/s7/s8/s9/s10/s11").get_global_pos()
	
	#if (not is_out_of_screen(globPos)):
	#print(get_global_pos())
	if (get_global_pos().x - width/2 < 1.0 && get_global_pos().y - height/2 < 1.0):
		justRespawned = false
	
	# respawn if out of screen
	if ( is_out_of_screen(globPos) and justRespawned == false ):
		print("RESPAWN")
		set_global_pos(get_parent().get_node("respawn_point").get_pos())
		look_at( Vector2(width/2, height/2))	 # look at center of screen
		justRespawned = true
	
	## ROTATION
	var ang = get_angle_to(get_pos()+ velocity.normalized())
	rotate( ang*delta*SMOOTH_SPEED )
	
	if (DEBUG):
		update()



func wander():
	# calculate center of displacement circle
	displacementCenter = Vector2(0, 1) * DISPLACEMENT_DISTANCE
	displacementForce = Vector2(0, 1) * DISPLACEMENT_MAX_RADIUS
	
	# Randomly change the vector direction by making it change its current angle
	var len = displacementForce.length()
	displacementForce.x = cos(wanderAngle) * len
	displacementForce.y = sin(wanderAngle) * len
	
	# Change wanderAngle just a bit, so it won't have the same value in the next game frame.
	wanderAngle += clamp(rand_range(-ANGLE_CHANGE, ANGLE_CHANGE),-PI, PI)
	
	var wanderForce = displacementCenter + displacementForce

	return wanderForce


func is_close_to_wall(pos):
	var distanceMax = 50
	if (pos.x <= distanceMax or pos.x >= width-distanceMax or pos.y <= distanceMax or pos.y >= height-distanceMax):
		return true
	else:
		return false

func is_out_of_screen(pos):
	if (pos.x < -50 or pos.x > width + 50 or pos.y < -50 or pos.y > height + 50):
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
	var velocity = (targetPos - get_pos()).normalized() * MAX_VELOCITY[color]
	var nextPosition = get_pos() + velocity
	set_pos(nextPosition)


func set_color(c):
	color = c
	
func get_color():
	return color