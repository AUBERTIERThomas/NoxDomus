extends Node
#---------------------------------------------------------------------------------
# CLASSE : Objet décoratif (pas utilisé)
#---------------------------------------------------------------------------------
var coordinates : Vector3 # Position dans la salle.
var typeProp : int # Type d'objet.
var object # Instance de l'objet.

func setup(type : int) -> void:
	typeProp = type
	object = load("res://Objets/porte.fbx")
	if type == 0:
		var rand = randf_range(0,1)
		var wall = randi() % 4
		if wall < 2:
			coordinates = Vector3(randf_range(-1.5,1.5),0,1.95*(wall*2 - 1))
		else :
			coordinates = Vector3(1.95*((wall-2)*2 - 1),0,randf_range(-1.5,1.5))
