extends Node2D

const OBJECT = preload("res://object.tscn")

const INITIAL_VELOCITY := 500.0

@onready var vpr := get_viewport_rect().size
@onready var halfW := vpr.x / 2
@onready var halfH := vpr.y / 2

const INTERVAL_TO_CREATE := 3.0
var count_down := 0.0

func _physics_process(delta):
	if count_down <= 0:
		create_new_object()
		count_down = INTERVAL_TO_CREATE
	else:
		count_down -= delta

func create_new_object():
	var new = OBJECT.instantiate()
	new.global_position = Vector2(randf_range(-halfW, halfW), halfH)
	new.linear_velocity = Vector2(randf_range(-0.5 * INITIAL_VELOCITY, 0.5 * INITIAL_VELOCITY), -1.8 * INITIAL_VELOCITY)
	add_child(new)
