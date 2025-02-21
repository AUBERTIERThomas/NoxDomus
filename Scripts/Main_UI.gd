extends Control

var mapButton
var returnButton
var upButton
var leftButton
var downButton
var rightButton

var minimap
var locPin

var currentRoom
var roomList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapButton = $MapButton
	mapButton.pressed.connect(self.OnMapButtonClick)
	returnButton = $Minimap/Return
	returnButton.pressed.connect(self.OnReturnButtonClick)
	upButton = $ChangeRoom/UpArrow
	upButton.pressed.connect(self.OnUpButtonClick)
	leftButton = $ChangeRoom/LeftArrow
	leftButton.pressed.connect(self.OnLeftButtonClick)
	downButton = $ChangeRoom/DownArrow
	downButton.pressed.connect(self.OnDownButtonClick)
	rightButton = $ChangeRoom/RightArrow
	rightButton.pressed.connect(self.OnRightButtonClick)
	minimap = $Minimap
	locPin = $Minimap/LocPin
	roomList = minimap.rList
	currentRoom = roomList[0]
	print(currentRoom.coordinates)
	print(currentRoom.links)
	
	ShowButtons()
	
	
	
	
	pass # Replace with function body.

func ShowButtons() -> void: #Je suis le pire programmeur pour avoir fait ça mais je préferrais éviter de faire une liste de boutons pour la clarté voilà du coup je fais les 4 cas à la main mais bon on pourra pas dire que c'est pas lisible et tout haha allez sur ce bonne lecture.
	if !currentRoom.links[3]:
		upButton.hide()
	else:
		upButton.show()
	if !currentRoom.links[2]:
		leftButton.hide()
	else:
		leftButton.show()
	if !currentRoom.links[1]:
		downButton.hide()
	else:
		downButton.show()
	if !currentRoom.links[0]:
		rightButton.hide()
	else:
		rightButton.show()

func OnMapButtonClick() -> void:
	get_node("Minimap").show()
	get_node("ChangeRoom").hide()

func OnReturnButtonClick() -> void:
	get_node("Minimap").hide()
	get_node("ChangeRoom").show()

func OnUpButtonClick() -> void:
	FindNextRoom(Vector2(0,1))
	ShowButtons()

func OnLeftButtonClick() -> void:
	FindNextRoom(Vector2(1,0))
	ShowButtons()

func OnDownButtonClick() -> void:
	FindNextRoom(Vector2(0,-1))
	ShowButtons()

func OnRightButtonClick() -> void:
	FindNextRoom(Vector2(-1,0))
	ShowButtons()

func FindNextRoom(dec : Vector2) -> void:
	print(dec)
	var new_c = currentRoom.coordinates+dec
	for c in roomList:
		if (c.coordinates == new_c):
			currentRoom = c
			break
	locPin.position = locPin.position - dec * minimap.space
	print(locPin.position)
	print(currentRoom.coordinates)
