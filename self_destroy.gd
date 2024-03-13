extends RigidBody2D

class_name SelfDestroyBody

func _physics_process(_delta):
	var maxH = get_viewport_rect().size.y
	if global_position.y > maxH:
		queue_free()
