extends Node2D

var map_node = preload("res://entities/map_nodes/basic_map_node.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#NOTE: currently i believe this randomly generates a new map every time the scene is opened
	#i will look into making sure it only generates 1 time
	var map = []
	var node_spacing = 60
	for i in range(1,16):
		map.append([0,0,0])
		#Starting + Ending node
		if i==1 or i==15:
			map[i-1][1] = map_node.instantiate()
			map[i-1][1].position += Vector2(node_spacing*i,300)
			map[i-1][1].scale = Vector2(2,2)
		else:
			var num_nodes = randi_range(1,3)
			if num_nodes == 1:
				map[i-1][1] = map_node.instantiate()
				map[i-1][1].position += Vector2(node_spacing*i,300)
				map[i-1][1].scale = Vector2(2,2)
			elif num_nodes == 2:
				map[i-1][0] = map_node.instantiate()
				map[i-1][0].position += Vector2(node_spacing*i,200)
				map[i-1][0].scale = Vector2(2,2)
				map[i-1][2] = map_node.instantiate()
				map[i-1][2].position += Vector2(node_spacing*i,400)
				map[i-1][2].scale = Vector2(2,2)
			else:
				map[i-1][0] = map_node.instantiate()
				map[i-1][0].position += Vector2(node_spacing*i,200)
				map[i-1][0].scale = Vector2(2,2)
				map[i-1][1] = map_node.instantiate()
				map[i-1][1].position += Vector2(node_spacing*i,300)
				map[i-1][1].scale = Vector2(2,2)
				map[i-1][2] = map_node.instantiate()
				map[i-1][2].position += Vector2(node_spacing*i,400)
				map[i-1][2].scale = Vector2(2,2)
	for i in map:
		for x in i:
			#if not int (aka an object)
			if typeof(x) != 2:
				self.add_child(x)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
