extends Node2D

var map_node = preload("res://entities/map_nodes/basic_map_node.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#10/30/2026: Added randomizer variable based on Runstate random number generator
	var random = RunState.rng
	var map = []
	#10/30/2026: Renamed node_spacing to h_node_spacing, made it a const
	#added v_node_spacing
	#added v_node_pos (position of nodes in regard to verticality)
	#added node_scale (how much nodes are sized up)
	const h_node_spacing = 60
	const v_node_spacing = 100
	const v_node_pos = 300
	const node_scale = 2
	for i in range(1,16):
		map.append([0,0,0])
		#Starting + Ending node
		if i==1 or i==15:
			map[i-1][1] = map_node.instantiate()
			map[i-1][1].position += Vector2(h_node_spacing*i,v_node_pos)
			map[i-1][1].scale = Vector2(node_scale,node_scale)
		else:
			#10/30/2026: Updated with game random seed
			var num_nodes = random.randi_range(1,3)
			#10/30/2026: Replaced extended conditional statement with for loop
			for x in range(0,3):
				#if 1 node: place in middle
				#if 2 nodes: place on top & bottom
				#if 3 nodes: fill all slots
				if (num_nodes==1 and x==1
				or  num_nodes==2 and (x==0 or x==2)
				or  num_nodes==3):
					map[i-1][x] = map_node.instantiate()
					map[i-1][x].position += Vector2(h_node_spacing*i,v_node_pos+(x-1)*v_node_spacing)
					map[i-1][x].scale = Vector2(node_scale,node_scale)
	for i in map:
		for x in i:
			#if not int (aka an object)
			if typeof(x) != 2:
				self.add_child(x)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
