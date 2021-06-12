extends RigidBody2D

export(String) var style

func avg(arr):
	var uwu = Vector2.ZERO
	for u in arr:
		uwu += u
	uwu /= len(arr)
	return uwu

func _ready():
	var shape = $Template
	set_shape(shape.polygon)
	$Template.modulate.a = 0 
	if style != "branch":
		$Line2D.queue_free()

func set_shape(shape):
	$GlueablePiece.position = Vector2.ZERO
	var minx = 0
	var maxx = 0
	var miny = 0
	var maxy = 0
	for i in shape:
		minx = min(i.x,minx)
		miny = min(i.y,miny)
		maxx = max(i.x,maxx)
		maxy = max(i.y,maxy)
	var width = maxx-minx
	var height = maxy-miny
	var av = avg(shape)
	var shape2 = PoolVector2Array(Array(shape).duplicate())
	for i in range(len(shape)):
		shape[i] -= av
		shape2[i] -= Vector2(width,height)/2
	$GlueablePiece.polygon = shape
	var s = ConvexPolygonShape2D.new()
	s.points = shape
	var so = create_shape_owner(self)
	shape_owner_add_shape(so,s)
	global_position = $Template.global_position
	if style == "branch":
		shape.append(shape[0])
		$Line2D.points = shape
	

var dragging = false
var dragorigin = true

func _process(delta):
	if !Global.play_mode:
		if !Input.is_action_pressed("MouseDown"):
			self.dragging=false
			Global.dragging_something=false
		if Input.is_action_just_pressed("MouseDown"):
			if !Global.dragging_something:
				if hover:
	#				print("md!")
					Global.dragging_something = true
					self.dragorigin=get_local_mouse_position()
					self.dragging = true
		if self.dragging:
			self.mode=RigidBody2D.MODE_KINEMATIC
			var mv : Vector2 = get_local_mouse_position()-dragorigin
			if mv.length()>20*60*delta:
				mv=mv.normalized()*20*60*delta
			self.position+=mv
		else:
			self.mode=RigidBody2D.MODE_RIGID
	else:
		self.mode=RigidBody2D.MODE_RIGID

var hover = false

func _on_RigidBody2D_mouse_entered():
	hover = true
#	print("hov")
func _on_RigidBody2D_mouse_exited():
	hover = false

