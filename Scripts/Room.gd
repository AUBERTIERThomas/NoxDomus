extends Node

var coordinates : Vector2
var typeRoom : int
var links : Array

func setup(c : Vector2, type : int) -> void:
	coordinates = c
	typeRoom = type
	links = [false,false,false,false]
