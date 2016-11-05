
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_process(true)
	pass

func _process(delta):
	if get_node("AnimationPlayer").is_playing() == false:
		queue_free()
