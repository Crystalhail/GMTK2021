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
		lev.connect("mouse_entered",self,"hover_level",[lev])
		lev.connect("mouse_entered",self,"play_level",[level])

func hover_button(n):
	$Main.move_child(n,get_child_count()-1)
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1.1,1.1),0.6,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
	
func unhover_button(n):
	$Tween.stop(n)
	$Tween.interpolate_property(n,"rect_scale",null,Vector2(1,1),0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()

func hover_level(n):
	$Tween.stop($NinePatchRect)
	$Tween.interpolate_property($NinePatchRect,"modulate:a",null,1,0.4)
	$Tween.interpolate_property($NinePatchRect,"rect_size",null,n.rect_size - Vector2(14,14),0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($NinePatchRect,"rect_global_position",null,n.rect_global_position + Vector2(7,7),0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()


func _on_StartButton_pressed():
	$Tween.interpolate_property($Main,"rect_global_position:x",0,-1024,0.7,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($Levels,"rect_global_position:x",1024,0,0.7,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()

func Levels_Go_Back():
	$Tween.stop($NinePatchRect)
	$Tween.interpolate_property($NinePatchRect,"modulate:a",null,0,0.2)
	$Tween.interpolate_property($NinePatchRect,"rect_size",null,rect_size,0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($NinePatchRect,"rect_global_position",null,Vector2.ZERO,0.4,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($Main,"rect_global_position:x",-1024,0,0.7,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($Levels,"rect_global_position:x",0,1024,0.7,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
	
func play_level(n):
	pass
