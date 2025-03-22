extends Node
#---------------------------------------------------------------------------------
# Test de texture sur le torus (plus utilisé).
#---------------------------------------------------------------------------------

func _ready() -> void:
	self.transform.origin = Vector3(randf_range(-5,5),0,randf_range(-5,5))
	self.rotation = Vector3(50,20,10)
	#var material = StandardMaterial3D.new()
	#self.material = StandardMaterial3D.new()
	#self.material.albedo_color = Color(0, 1, 0)  # Vert
	var material = StandardMaterial3D.new()
	material.albedo_color = Color8(0,255,0)
	self.material_override = material
