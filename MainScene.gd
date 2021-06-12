extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func detect_position_overlaps():
	var glueable = get_tree().get_nodes_in_group("glueable")
	var objects_points = []
	for p in glueable:
		var poly = p.get_node("GlueablePiece").polygon
		for point in range(len(poly)):
			poly[point] += p.get_node("GlueablePiece").global_position
		objects_points.append(poly)
		
	var reference_copy = objects_points.duplicate()
	
	var current
	var results = []
	for i in range(len(objects_points)):
		current = objects_points.pop_front()
		for cur in current: # For all points of the selected object
			for o in objects_points: # For all other objects
				for e in o: # For all points of the forlooped object from above line
					if cur.distance_to(e) < 0.5:
						var first = i
						var firstA = Array(reference_copy[first]).find(cur)
						var second = reference_copy.find(o)
						var secondA = Array(reference_copy[second]).find(e)
						results.append([first,firstA,second,secondA])
		objects_points.append(current)
	
	

func _ready():
	detect_position_overlaps()

func _process(delta):
	if Input.is_action_just_pressed("Retry"):
		get_tree().reload_current_scene()
