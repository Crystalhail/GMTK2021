extends RigidBody2D

func _process(delta):
	if Global.play_mode:
		self.mode=RigidBody2D.MODE_RIGID
	else:
		self.mode=RigidBody2D.MODE_STATIC
