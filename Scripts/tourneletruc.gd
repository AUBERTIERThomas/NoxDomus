extends CSGTorus3D

var angle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Vector3(randf_range(-5,5),0,randf_range(-5,5))
	angle = 0
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	angle += delta
	if (angle > 360) :
		angle -= 360
	#get_node("CSGTorus3D").rotate_y(deg_to_rad(angle))
	self.rotation = Vector3(angle,2*angle,angle)
	pass
