extends SelfDestroyBody

class_name ObjectBody

# Parameters
@export var hp := 5

const FORCE_RATIO := 25.0
const MAX_FORCE_V := 80.0
const MAX_BREAK_WEIGHT := 3.0

# Normal
const idle = preload("res://Resource/Barrel/Idle/1.png")

# Hit animation
const hit_1 = preload("res://Resource/Barrel/Hit/1.png")
const hit_2 = preload("res://Resource/Barrel/Hit/2.png")
const hit_3 = preload("res://Resource/Barrel/Hit/3.png")
const hit_4 = preload("res://Resource/Barrel/Hit/4.png")
const hit_frames = [hit_1, hit_2, hit_3, hit_4]
var is_plaing_hit_animation := false

# Explosion
const PIECE = preload("res://piece.tscn")
const part_1 = preload("res://Resource/Barrel/Destroyed/2.png")
const part_2 = preload("res://Resource/Barrel/Destroyed/3.png")
const part_3 = preload("res://Resource/Barrel/Destroyed/4.png")
const part_4 = preload("res://Resource/Barrel/Destroyed/5.png")
const part_frames = [part_1, part_2, part_3, part_4]

@onready var sprite_2d = $Sprite2D

# Detect mouse press event & Apply force to object
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		#print("Mouse Click at: ", get_global_mouse_position())
		#print("Body at: ", global_position)
		var shift = get_global_mouse_position() - global_position
		var base = -(shift.normalized() * FORCE_RATIO + Vector2(0, MAX_FORCE_V))
		var impluse = clamp(base, Vector2(-FORCE_RATIO, -MAX_FORCE_V), Vector2(FORCE_RATIO, FORCE_RATIO-MAX_FORCE_V))
		apply_impulse(impluse, shift)
		_on_collided()

func _on_body_entered(body):
	if body is ObjectBody:
		_on_collided()

func _on_collided():
	hp -= 1
	do_hit_animation()
	if hp <= 0:
		explode()
		
# 20 FPS
func do_hit_animation():
	if not is_plaing_hit_animation:
		is_plaing_hit_animation = true
		for f in hit_frames:
			sprite_2d.texture = f
			await get_tree().create_timer(0.05).timeout
		sprite_2d.texture = idle
		is_plaing_hit_animation = false
		
func explode():
	print("linear_velocity: ", linear_velocity)
	print("angular_velocity: ", angular_velocity)
	var vx = divideVelocity(linear_velocity.x)
	var vy = divideVelocity(linear_velocity.y)
	var av = divideVelocity(angular_velocity)
	print("vy: ", vy)
	
	var numbers_of_parts = part_frames.size()
	for i in range(numbers_of_parts):
		var p = PIECE.instantiate()
		p.new_gravity_scale = gravity_scale
		p.new_mass = mass / float(numbers_of_parts)
		p.texture = part_frames[i]
		var v = Vector2(vx.x, vy.x)
		var a = av.x
		match i:
			1: 
				v = Vector2(vx.y, vy.y)
				a = av.y
			2: 
				v = Vector2(vx.z, vy.z)
				a = av.z
			3: 
				v = Vector2(vx.w, vy.w)
				a = av.w
		p.linear_velocity = v
		p.angular_velocity = a
		p.global_position = global_position
		get_parent().call_deferred("add_child", p)
	queue_free()
	
# Conservation of Momentum: m x v = m1 x v1 + m2 x v2 + m3 x v3 + m4 x v4
# Assume: 1 / 4 x m == m1 == m2 == m3 == m4
# 	  ==> 4 x v = v1 + v2 + v3 + v4
func divideVelocity(origin: float):
	#var abs = abs(origin)
	var maxV = MAX_BREAK_WEIGHT * origin #clampf(abs, 1, abs) * 1.0 if origin >= 0 else -1.0
	var w1 = randf_range(-maxV, maxV)
	var w2 = 4 * origin - w1
	var w3 = randf_range(0, w1)
	var w4 = randf_range(0, w2)
	w1 -= w3
	w2 -= w4
	return Vector4(w1, w2, w3, w4)
