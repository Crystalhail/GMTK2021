extends Node2D

var boulderCount = 0
var glued = []

export(int) var Glue_Max

class lineSort:
	static func v2i(vcs):
		var v1 = vcs[0]
		var v2 = vcs[1]
		var r = int(str(v1.x) + str(v1.y) + str(v2.x) + str(v2.y))
		return r
	
	static func sort_ascending(a, b):
		return v2i(a[0]) > v2i(b[0])

func vecround(vec):
	return Vector2(round(vec.x/10)*10,round(vec.y/10)*10)

func prepare_glue_button(vectors,buttonNode):
	var center = (vectors[0] + vectors[1])/2
	var width = vectors[0].distance_to(vectors[1])
	buttonNode.rect_size.x = width
	var localcenter = buttonNode.rect_size/2
	buttonNode.rect_pivot_offset = localcenter
	buttonNode.rect_global_position = center-localcenter
	buttonNode.rect_rotation = rad2deg(vectors[0].angle_to_point(vectors[1]))

func sort_two_points(p1,p2):
	p1 = vecround(p1)
	p2 = vecround(p2)
	if p1.x > p2.x:
		return [p1,p2]
	elif p1.x < p2.x:
		return [p2,p1]
	else:
		if p1.y > p2.y:
			return [p1,p2]
		else:
			return [p2,p1]

#[(670, 280), (670, 250)] ==  v1
#[(670, 280), (670, 240)]     v2

func glue_bias(v1,v2):
	if v1 == []:return
	return (v1[0] - v2[0]).abs().length() < Vector2(10,10).length() and (v1[1] - v2[1]).abs().length() < Vector2(10,10).length()

func detect_position_overlaps():
	var glueable = get_tree().get_nodes_in_group("glueable")
	var objects_points = []
	for p in range(len(glueable)):
		var poly = glueable[p].get_node("GlueablePiece").polygon
		for point in range(len(poly)):
			poly[point] = poly[point].rotated(deg2rad(glueable[p].rotation_degrees))
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
		#yield(get_tree().create_timer(3),"timeout")
		if dupe[0] == dupeLine[0] or glue_bias(dupe[0],dupeLine[0]):
			if not ([dupe[1],dupe[2]] in glued or [dupeLine[1],dupeLine[2]] in glued):
				glueables.append([dupe,dupeLine])
		dupe = dupeLine
	for bt in $CanvasLayer.get_children():
		bt.queue_free()
	for g in glueables:
		if [g[0][1],g[0][2]] in glued: return
		$CanvasLayer.add_child($button.duplicate())
		prepare_glue_button(PoolVector2Array([g[0][0][0], g[0][0][1]]),$CanvasLayer.get_children()[-1])
		$CanvasLayer.get_children()[-1].connect("button_down",self,"glue",[
			glueable[g[0][1]],
			glueable[g[1][1]],
			g[0][0][0],
			g[0][0][1],
			[g[0][1],g[0][2]]
			])
	return glueables

func editmode():
	Global.play_mode = false
	for gl in get_tree().get_nodes_in_group("glueable"):
		gl.collision_mask = 0
		gl.collision_layer = 2

func playmode():
	Global.play_mode = true
	$OnScreenUI/Play.hide()
	for gl in get_tree().get_nodes_in_group("glueable"):
		gl.collision_mask = 1
		gl.collision_layer = 1
		gl.gravity_scale=1
	for bl in get_tree().get_nodes_in_group("Boulder"):
		bl.gravity_scale = 1

func _ready():
	Global.glue_left = Glue_Max
	editmode()
	boulderCount = len(get_tree().get_nodes_in_group("Boulder"))
	for goal in get_tree().get_nodes_in_group("GoalPost"):
		goal.connect("body_entered",self,"goal_body_entered",[goal])
	Global.attempts += 1
	if Global.attempts > 1:
		$OnScreenUI/attempts.text = str(Global.attempts) + " attempts and counting..."
		$Tween.interpolate_property($OnScreenUI/attempts,"rect_position",Vector2(-357,555),Vector2(10,555),1,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.start()
		yield(get_tree().create_timer(2),"timeout")
		$Tween.interpolate_property($OnScreenUI/attempts,"rect_position",Vector2(10,555),Vector2(0,700),1,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.start()

func reset_level(clear=false):
	if clear: Global.attempts = 0
	get_tree().reload_current_scene()

func _process(delta):
	if !Global.play_mode: detect_position_overlaps()
	if Input.is_action_just_pressed("Retry"):
		reset_level()
	if Input.is_action_just_pressed("dbg_1"):
		playmode()
	if Input.is_action_just_pressed("let_me_out_of_brazil"):
		to_menu()

func to_menu():
	Global.opened_level = 0
	get_tree().change_scene("res://Resources/MainUI.tscn")

func next_level():
	Global.opened_level += 1
	get_tree().change_scene("res://Levels/Level" + str(Global.opened_level) + ".tscn")

func check_win():
	if boulderCount == 0:
		yield(get_tree().create_timer(1),"timeout")
		$OnScreenUI/Reset.hide()
		var winscreen = load("res://Resources/WinScreen.tscn").instance()
		if Global.opened_level == Global.level_count: winscreen.has_no_next()
		$OnScreenUI.add_child_below_node($OnScreenUI/gluebar,winscreen)
		winscreen.get_node("Retry").connect("pressed",self,"reset_level")
		winscreen.get_node("BackButton").connect("pressed",self,"to_menu")

func glue(obj1:Node2D,obj2:Node2D,point1:Vector2,point2:Vector2,fixate):
	if Global.glue_left == 0: return
	Global.glue_left -= 1
	$OnScreenUI/gluebar.value = Global.glue_left
	glued.append(fixate)
	var pj1 = PinJoint2D.new()
	obj1.add_child(pj1)
	pj1.softness=2
	pj1.node_a = pj1.get_path_to(obj1)
	pj1.node_b = pj1.get_path_to(obj2)
	pj1.global_position=point1
	
	var pj2 = PinJoint2D.new()
	obj2.add_child(pj2)
	pj2.softness=2
	pj2.node_a = pj2.get_path_to(obj2)
	pj2.node_b = pj2.get_path_to(obj1)
	pj2.global_position=point2
	
	var line = Line2D.new()
	line.texture = load("res://Images/gluestrand.png")
	line.default_color = Color.white
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	pj1.add_child(line)
	line.points = [Vector2(0,0),pj2.global_position-pj1.global_position]

func goal_body_entered(boulder,goal):
	#boulder = boulder.get_parent()
#	print(boulder.name)
	if boulder.is_in_group("Boulder"):
		boulder.gravity_scale = 0
		boulder.linear_velocity = Vector2.ZERO
		boulder.collision_layer = 0
		boulder.collision_mask = 0
		$Tween.interpolate_property(boulder,"position",null,goal.position,0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.interpolate_property(boulder,"scale",null,Vector2.ZERO,0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.interpolate_property(boulder,"modulate:a",null,0,0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.start()
		boulderCount -= 1
		check_win()

func _on_Tween_tween_completed(object, key):
	if object.is_in_group("Boulder"):
		if key == ":modulate:a":
			object.queue_free()

func _on_dbg_pressed():
	print(sort_two_points(Vector2(610, 380), Vector2(610, 420)))
	print(sort_two_points(Vector2(610, 420), Vector2(610, 380)))
