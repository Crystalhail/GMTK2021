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
	for i in range(len(shape)):
		smallerShape[i] *= 0.9
	$CollisionPolygon2D.polygon = smallerShape
	
	
