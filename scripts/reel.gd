extends Sprite


func _ready():
	get_node("Area2D").connect("input_event", self, "input_event")


func input_event(viewport, event, shape_idx):
	print(event)

	if (event.type == InputEvent.MOUSE_MOTION):
		rotate(get_angle_to(event.global_pos))