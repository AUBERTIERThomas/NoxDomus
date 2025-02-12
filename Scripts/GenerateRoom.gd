extends Node3D

#var arch_obj = preload("res://archeobj.obj")
var t1 = "res://Images//map3.jpg"
var c = preload("res://Rouge.tres")
var texture
var child_list

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	child_list = [$Mur1, $Mur2, $Mur3, $Mur4, $Plafond, $Sol]
	print(child_list.size())
	for i in range(6):
		print(child_list[i])
		#var v = Vector3(cos(i*PI/2)*10,sin(i*PI/2)*10,0)
		#var p = Vector3(0,0,90)
		#if(randi() % 2):
			#apply_texture(i)
		#else:
			#inst_plane(v,p,Vector3(3,3,10))
			#inst_arch(v,p,Vector3(3,3,10))
		apply_texture(i)
	print(self.child_list)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func apply_texture(id: int) -> void:
	var image = Image.new()
	image.load(t1)
	var tex = ImageTexture.create_from_image(image)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = tex
	child_list[id].set_surface_override_material(0, mat)
	pass

func inst_plane(pos: Vector3, rot: Vector3, sc: Vector3) -> void:
	var plane = MeshInstance3D.new()
	plane.mesh = PlaneMesh
	plane.set_surface_override_material(0,c)
	#plane.material_override = StandardMaterial3D.new()
	#plane.material_override.albedo_texture = t1
	plane.position = pos
	plane.rotation = rot
	plane.scale = sc
	self.add_child(plane)
	print(plane.position)
	pass

#func inst_arch(pos: Vector3, rot: Vector3, sc: Vector3) -> void:
	#var arch = MeshInstance3D.new()
	##arch.mesh = arch_obj
	##var mat = PlaneMesh.new() 
	##arch_obj.albedo_texture = t1
	#arch.mesh = arch_obj
	#arch.position = pos
	#arch.rotation = rot
	#arch.scale = sc
	#add_child(arch)
	#pass
