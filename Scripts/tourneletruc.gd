extends CSGTorus3D
#---------------------------------------------------------------------------------
# Tourne le torus (la mascotte finalement, là depuis le début).
#---------------------------------------------------------------------------------
var angle

func _ready() -> void:
	Vector3(randf_range(-5,5),0,randf_range(-5,5))
	angle = 0

func _process(delta: float) -> void:
	angle += delta
	# Modulo custom pour pas que le nombre devienne trop grand.
	if (angle > 360) :
		angle -= 360
	self.rotation = Vector3(angle,2*angle,angle)
