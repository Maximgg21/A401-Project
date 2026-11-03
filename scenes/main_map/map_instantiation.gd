extends Node2D
#11/3/2026: Moved vars + consts out of func _ready
const H_NODE_SPACING = 60
const V_NODE_SPACING = 100
const V_NODE_POS = 300
const NODE_SCALE = 2
#-
var random = RunState.rng
var map_node = preload("res://entities/map_nodes/basic_map_node.tscn")
var map: Array[Array] = []
#-
func _ready() -> void:
	for i in range(1,16):
		#10/31/2026: Defined sub-array type
		map.append([] as Array[Node2D])
		#Starting + Ending node
		if i==1 or i==15:
			map[i-1].append(map_node.instantiate())
			map[i-1][0].position += Vector2(H_NODE_SPACING*i,V_NODE_POS)
			map[i-1][0].scale = Vector2(NODE_SCALE,NODE_SCALE)
			if i==1:
				#NOTE: REPLACE THIS WITH WHATEVER ENDS UP BEING THE START NODE
				map[0][0].set_room("res://scenes/levels/game.tscn")
		else:
			#10/30/2026: Updated with game random seed
			var num_nodes = random.randi_range(1,3)
			#10/30/2026: Replaced extended conditional statement with for loop
			#10/31/2026: Changed logic, append based array filling
			for x in range(0,3):
				#establish placement for nodes
				var node_placement = x-1
				if num_nodes==1:
					node_placement = 0
				elif num_nodes==2:
					if x==0:
						node_placement = -1
					else:
						node_placement = 1
				#-
				map[i-1].append(map_node.instantiate())
				map[i-1][x].position += Vector2(H_NODE_SPACING*i,V_NODE_POS+(node_placement)*V_NODE_SPACING)
				map[i-1][x].scale = Vector2(NODE_SCALE,NODE_SCALE)
				#-
				if num_nodes == 1:
					break
				elif num_nodes == 2 and x==1:
					break
				#-
				map[0][0].set_open()
	for i in map:
		for x in i:
			#10/31/2026: Removed int conditional
			self.add_child(x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
