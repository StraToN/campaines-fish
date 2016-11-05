
extends Node2D

var currentDestination
var DEST_BORDER_GAP = 50.0
var timerNewDestination

var spriteBubble = null

var MAX_VELOCITY = 1.0
var speed = 10.0
var rotSpeed = 15.0



func _ready():

	# charger bubulle
	var resBubble = preload("res://graphics/bubble.png")
	spriteBubble = Sprite.new()
	spriteBubble.set_texture(resBubble)
	spriteBubble.set_centered(true)
	get_parent().get_node("background").add_child(spriteBubble)

	timerNewDestination = Timer.new()
	timerNewDestination.set_wait_time(3)
	timerNewDestination.set_autostart(true)
	add_child(timerNewDestination)
	timerNewDestination.connect("timeout", self, "new_destination")

	# Preparer destinations
	randomize()
	new_destination()
	
	set_fixed_process(true)


func _fixed_process(delta):
	seek(currentDestination, delta)
	
	pass
	
func new_destination():
	currentDestination = Vector2(int(rand_range(DEST_BORDER_GAP, get_parent().get_viewport_rect().size.x - DEST_BORDER_GAP)), int(rand_range(DEST_BORDER_GAP, get_parent().get_viewport_rect().size.y - DEST_BORDER_GAP)) )
	spriteBubble.set_pos(currentDestination)
	timerNewDestination.stop()
	timerNewDestination.start()


func seek(targetPos, delta):
	var displacement = targetPos - get_pos()
	if (displacement.x < 10 and displacement.y < 10):
		new_destination()

	var velocity = (targetPos - get_pos()).normalized() * MAX_VELOCITY
	var nextPosition = get_pos() + velocity
	
	printt("Current pos = ", get_pos())
	printt("Next pos = ", nextPosition)
	printt("Destination = ", currentDestination, "\n")
	set_pos(nextPosition)

