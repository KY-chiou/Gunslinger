extends SelfDestroyBody

class_name Piece

# Parameters to be set
var texture: Texture2D
var new_mass: float
var new_gravity_scale: float

func _ready():
	%Sprite.texture = texture
	mass = new_mass
	gravity_scale = new_gravity_scale
