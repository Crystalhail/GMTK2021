extends Node2D

class lineSort:
	static func v2i(vcs):
		var v1 = vcs[0]
		var v2 = vcs[1]
		var r = int(str(v1.x) + str(v1.y) + str(v2.x) + str(v2.y))
		return r
	
	static func sort_ascending(a, b):
		return v2i(a[0]) > v2i(b[0])

func vecround(vec):
	return Vector2(round(vec.x/5)*5,round(vec.y/5)*5)
	
	
func prepare_glue_button(vectors,buttonNode):
	print(vectors)
	var center = (vectors[0] + vectors[1])/2
	var width = vectors[0].distance_to(vectors[1])
	buttonNode.rect_size.x = width
	var localcenter = buttonNode.rect_size/2
	buttonNode.rect_pivot_offset = localcenter
	buttonNode.rect_global_position = center-localcenter
	buttonNode.rect_rotation = rad2deg(vectors[0].angle_to_point(vectors[1]))
	

func sort_two_points(p1,p2):
	if p1.x > p2.x:
		return [vecround(p1),vecround(p2)]
	elif p1.x < p2.x:
		return [vecround(p2),vecround(p1)]
	else:
		if p1.y > p2.y:
			return [vecround(p1),vecround(p2)]
		else:
			return [vecround(p2),vecround(p1)]

func detect_position_overlaps():
	var glueable = get_tree().get_nodes_in_group("glueable")
	var objects_points = []
	for p in range(len(glueable)):
		var poly = glueable[p].get_node("GlueablePiece").polygon
		for point in range(len(poly)):
			poly[point] += glueable[p].get_node("GlueablePiece").global_position
		objects_points.append(poly)
	var lines = []
	for x in range(len(objects_points)):
		for y in range(len(objects_points[x])):
			lines.append([sort_two_points(objects_points[x][y], objects_points[x][(y+1)%len(objects_points[x])]),x,y])
	lines.sort_custom(lineSort,"sort_ascending")
	var dupe = [[]]
	var glueables = []
	for dupeLine in lines:
		if dupe[0] == dupeLine[0]:
			glueables.append([dupe,dupeLine])
		dupe = dupeLine
	for g in glueables:
		prepare_glue_button(PoolVector2Array([g[0][0][0], g[0][0][1]]),$CanvasLayer.get_children()[-1])
		$CanvasLayer.add_child($CanvasLayer.get_children()[-1].duplicate())
	return glueables
	
	
	
func _ready():
	detect_position_overlaps()
	

func _process(delta):
	if Input.is_action_just_pressed("Retry"):
		get_tree().reload_current_scene()

func glue(obj1:Node2D,obj2:Node2D,point1:Vector2,point2:Vector2):
	var pj1 = PinJoint2D.new()
	pj1.softness=2
	pj1.node_a = obj1
	pj1.node_b = obj2
	pj1.global_position=point1
	obj1.add_child(pj1)
	var pj2 = PinJoint2D.new()
	pj2.softness=2
	pj2.node_a = obj2
	pj2.node_b = obj1
	pj2.global_position=point2
	obj2.add_child(pj2)
