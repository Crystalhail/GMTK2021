extends TextureButton

var normal_text = ""
export var hover_text = ""

func _ready():
	normal_text = $Label.text
	connect("mouse_entered",self,"mouseenter")
	connect("mouse_exited",self,"mouseexit")

func mouseenter():
	$Label.text=hover_text

func mouseexit():
	$Label.text=normal_text
