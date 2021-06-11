extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_shape(PoolVector2Array([
		Vector2(0,0),
		Vector2(50,0),
		Vector2(50,50),
		Vector2(0,50),
		]))

func set_shape(shape):
	$GlueablePiece.polygon = shape
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
	var off = Vector2(width,height)*0.05 #0.05 is half of 1-0.9
	for i in range(len(shape)):
		smallerShape[i] *= 0.9
		smallerShape[i] += off
	$CollisionPolygon2D.polygon = smallerShape
	
	
