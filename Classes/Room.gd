extends Node

var coordinates : Vector2
var typeRoom : int
var isRevealed : bool
var links : Array
var lightState : int
var lightStateList = [60,85]

func setup(c : Vector2, type : int) -> void:
	coordinates = c
	typeRoom = type
	isRevealed = true # Mettre en true pour tout révéler
	links = [false,false,false,false]
	lightState = 0
	var ls = randi() % 100
	for i in range(lightStateList.size()):
		if ls >= lightStateList[i]:
			lightState += 1
