extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for b in get_tree().get_nodes_in_group("hoverableButton"):
		b.connect("mouse_entered",self,"hover_button",[b])
		b.connect("mouse_exited",self,"unhover_button",[b])

func hover_button(n):
	move_child(n,get_child_count()-1)
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1.1,1.1),0.6,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
	
func unhover_button(n):
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1,1),0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
