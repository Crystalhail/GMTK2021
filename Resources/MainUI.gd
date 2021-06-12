extends TextureRect

onready var level_button = preload("res://Resources/LevelButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in get_tree().get_nodes_in_group("hoverableButton"):
		b.connect("mouse_entered",self,"hover_button",[b])
		b.connect("mouse_exited",self,"unhover_button",[b])
	for level in range(12):
		var lev = level_button.instance()
		lev.name = str(level+1) #IMPORTANT
		$Levels/Levelgrid.add_child(lev)

func hover_button(n):
	move_child(n,get_child_count()-1)
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1.1,1.1),0.6,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
	
func unhover_button(n):
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1,1),0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
