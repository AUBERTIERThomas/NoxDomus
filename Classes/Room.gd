extends Node

var coordinates : Vector2
var typeRoom : int
var isRevealed : bool
var links : Array

func setup(c : Vector2, type : int) -> void:
	coordinates = c
	typeRoom = type
	isRevealed = false # Mettre en true pour tout révéler
	links = [false,false,false,false]
