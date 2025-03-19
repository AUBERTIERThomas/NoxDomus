extends Control

var mapButton
var returnButton
var upButton
var leftButton
var downButton
var rightButton
var doomBar
var doomBarValue

var minimap
var locPin
var locPinStartPos

var currentRoom
var roomList

signal change_room

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
	doomBar = $DoomBar
	doomBarValue = $DoomBarValue
	minimap = $Minimap
	locPin = $Minimap/LocPin
	locPinStartPos = locPin.position
	roomList = minimap.rList
	currentRoom = roomList[0]
	currentRoom.isRevealed = true
	minimap.changeTexture(0)
	#print(currentRoom.coordinates)
	#print(currentRoom.links)
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
	get_node("DoomBar").hide()

func OnReturnButtonClick() -> void:
	get_node("Minimap").hide()
	get_node("ChangeRoom").show()
	get_node("DoomBar").show()

func OnUpButtonClick() -> void:
	FindNextRoom(0,Vector2(0,1))
	ShowButtons()

func OnLeftButtonClick() -> void:
	FindNextRoom(0,Vector2(1,0))
	ShowButtons()

func OnDownButtonClick() -> void:
	FindNextRoom(0,Vector2(0,-1))
	ShowButtons()

func OnRightButtonClick() -> void:
	FindNextRoom(0,Vector2(-1,0))
	ShowButtons()

func FindNextRoom(event : int,dec : Vector2) -> void:
	var new_i = 0
	var new_c
	if event == 1 : # Choix d'une salle déjà fait (téléportation)
		new_c = dec
	else :  # Changement de salle avec les flèches (classique)
		new_c = currentRoom.coordinates+dec
	for i in range(roomList.size()):
		if (roomList[i].coordinates == new_c):
			new_i = i
			break
	currentRoom = roomList[new_i]
	currentRoom.isRevealed = true
	locPin.position = locPinStartPos - currentRoom.coordinates * minimap.space
	minimap.changeTexture(new_i)
	print(locPin.position)
	print(currentRoom.coordinates)
	doomBar.value += 1
	doomBarValue.text = str(doomBar.value)
	emit_signal("change_room",new_i)
