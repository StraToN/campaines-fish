
extends Node2D

var arrFishColors = ["green", "pink", "blue", "yellow"]

func _ready():
	set_process_input(true)
	randomize()
	for i in range(1,10):
		var fish = preload("res://scenes/blue_fish.tscn").instance()
		fish.set_color(arrFishColors[randi() % arrFishColors.size()])
		#fish.set_pos(get_c)
		add_child(fish)
	
	pass

func _input(event):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		var mpos = event.global_pos
		
		var ripple = preload("res://scenes/ripple.scn").instance()
		ripple.set_pos(mpos)
		ripple.get_node("AnimationPlayer").play("wave")
		add_child( ripple )
	pass

func _process():
	pass
	
	
