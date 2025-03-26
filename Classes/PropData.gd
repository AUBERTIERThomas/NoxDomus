extends Node
#---------------------------------------------------------------------------------
# CLASSE : Objet décoratif (pas utilisé)
#---------------------------------------------------------------------------------
var coordinates : Vector3 # Position dans la salle.
var typeProp : int # Type d'objet.
var object # Instance de l'objet.

func setup(type : int, id : int) -> void:
	var propList = ["Objets/WoodenTable.glb"]
	typeProp = type
	#var gltf_document_load = GLTFDocument.new()
	#var gltf_state_load = GLTFState.new()
	#var error = gltf_document_load.append_from_file(propList[typeProp], gltf_state_load)
	#if error == OK:
	#	var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
	#	gltf_scene_root_node.name = str(id)
	#else:
	#	print("shit")
	print("heheheha")
	#if type == 0:
	#	var rand = randf_range(0,1)
	#	var wall = randi() % 4
	#	if wall < 2:
	#		coordinates = Vector3(randf_range(-1.5,1.5),0,1.95*(wall*2 - 1))
	#	else :
	#		coordinates = Vector3(1.95*((wall-2)*2 - 1),0,randf_range(-1.5,1.5))
