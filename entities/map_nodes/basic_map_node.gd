extends Node2D
#instance IDs of the nodes this node is connected to
var next_node = [0,0,0]
var room_info
var scene
var is_open = 0
#NOTE: may scrap this entirely
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
func set_room(room):
	room_info = room
	#loads data as soon as avaliable?
	scene = load(room_info) # <- Scene then gets used to open room scene from main map
func set_open():
	is_open = 1
	#NOTE: set changing visual indicator for what is open?
func set_closed():
	is_open = 0
#func open_room(): <- NOTE: WORK ON THIS. path input
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
