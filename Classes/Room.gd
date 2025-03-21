extends Node
#---------------------------------------------------------------------------------
# CLASSE : Salle
#---------------------------------------------------------------------------------
var coordinates : Vector2 # Position dans le manoir.
var typeRoom : int # Type de salle.
var isRevealed : bool # Si la salle est révélée sur la minimap.
var links : Array # Présence ou non de salles adjacentes.
var lightState : int # État de la lumière.
var extraData : int # Si certains types de salle ont besoin d'une donnée en plus.

func setup(c : Vector2, type : int) -> void:
	coordinates = c
	typeRoom = type
	isRevealed = false # Mettre en true pour tout révéler
	links = [false,false,false,false]
	lightState = 0
	extraData = 0
	var ls = randi() % 100
	var lightStateList = [60,85] # Proportion d'état de la lumière
	for i in range(lightStateList.size()):
		if ls >= lightStateList[i]:
			lightState += 1
