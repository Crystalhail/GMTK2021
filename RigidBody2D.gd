extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_children()[1]
	set_shape(shape.polygon)

func set_shape(shape):
	$GlueablePiece.polygon = shape
	$GlueablePiece.position = Vector2.ZERO
	var smallerShape = PoolVector2Array(Array(shape).duplicate())
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
#	print(Vector2(width,height))
	var off = Vector2(width,height)*0.05 #0.05 is half of 1-0.9
	for i in range(len(shape)):
		smallerShape[i] *= 0.9
		smallerShape[i] += off
		smallerShape[i] -= Vector2(width,height)/2
	$GlueablePiece.position -= Vector2(width,height)/2
	position += Vector2(width,height)/2
	var s = ConvexPolygonShape2D.new()
	s.points = smallerShape
	var so = create_shape_owner(self)
	shape_owner_add_shape(so,s)
	
	
