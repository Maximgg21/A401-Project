extends Node2D
#instance IDs of the nodes this node is connected to
var next_node = [0,0,0]
#var room_info

func set_next(num,next1,next2=0,next3=0):
	if num == 1:
		next_node[1] = next1.get_instance_id()
	elif num == 2:
		next_node[0] = next1.get_instance_id()
		next_node[2] = next2.get_instance_id()
	else:
		next_node[0] = next1.get_instance_id()
		next_node[1] = next2.get_instance_id()
		next_node[2] = next3.get_instance_id()
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
