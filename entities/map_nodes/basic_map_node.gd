extends Node2D

class_name MapNode

#instance IDs of the nodes this node is connected to
var nextNode = [0,0,0]
var RoomInfo

func setNext(num,next1,next2=0,next3=0):
	pass
	if num == 1:
		nextNode[1] = next1.get_instance_id()
	elif num == 2:
		nextNode[0] = next1.get_instance_id()
		nextNode[2] = next2.get_instance_id()
	else:
		nextNode[0] = next1.get_instance_id()
		nextNode[1] = next2.get_instance_id()
		nextNode[2] = next3.get_instance_id()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
