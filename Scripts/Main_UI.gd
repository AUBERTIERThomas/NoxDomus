extends Control
#---------------------------------------------------------------------------------
# Assez fourre-tout, mais :
# Gère toutes les interactions avec l'UI principal. Ça comprend l'affichage de la
# minimap, le déplacement de salle, la barre de malédiction, le compteur de clef
# et la recherche de la salle suivante.
#---------------------------------------------------------------------------------
var mapButton
var returnButton
var upButton
var leftButton
var downButton
var rightButton
var doomBar
var doomBarValue
var screamerImage
var screamerList = [preload("res://Images//Screamer0.png"),preload("res://Images//Screamer1.png")] # ;)

var minimap
var locPin
var locPinStartPos

var currentRoom
var roomList

signal change_room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapButton = $Overlay/MapButton
	mapButton.pressed.connect(self.OnMapButtonClick)
	returnButton = $Minimap/Return
	returnButton.pressed.connect(self.OnReturnButtonClick)
	upButton = $Overlay/ChangeRoom/UpArrow
	upButton.pressed.connect(self.OnUpButtonClick)
	leftButton = $Overlay/ChangeRoom/LeftArrow
	leftButton.pressed.connect(self.OnLeftButtonClick)
	downButton = $Overlay/ChangeRoom/DownArrow
	downButton.pressed.connect(self.OnDownButtonClick)
	rightButton = $Overlay/ChangeRoom/RightArrow
	rightButton.pressed.connect(self.OnRightButtonClick)
	doomBar = $Overlay/DoomBar
	doomBarValue = $Overlay/DoomBarValue
	screamerImage = $OoohVeryScary
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

# Tire à chaque frame si un screamer est déclanché.
func _process(_delta: float) -> void:
	var screamer = randi() % 10000 # Plus le nombre est petit, plus ça arrive souvent.
	if screamer == 0:
		var sType = randi() % screamerList.size()
		screamerImage.texture = screamerList[sType]
		screamerImage.show()
		await get_tree().create_timer(0.75).timeout # Affiche l'image pendant 0.75 secondes.
		screamerImage.hide()
	pass

# Montre les boutons de déplacements correspondant aux salles adjacentes.
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

# Boutons pour afficher la minimap.
func OnMapButtonClick() -> void:
	get_node("Minimap").show()
	get_node("Overlay").hide()

# Boutons pour cacher la minimap.
func OnReturnButtonClick() -> void:
	get_node("Minimap").hide()
	get_node("Overlay").show()

# Boutons de déplacements.
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

# Trouver la salle correspondante au déplacement. Met à jour la malédiction et avertis certains scripts (voir GenerateRoom.gd).
func FindNextRoom(event : int,dec : Vector2) -> void:
	var new_i = 0
	var new_c
	# Choix d'une salle déjà fait (téléportation).
	if event == 1 :
		new_c = dec
	# Changement de salle avec les flèches (classique).
	else :
		new_c = currentRoom.coordinates+dec
	# Recherche exhaustive.
	for i in range(roomList.size()):
		if (roomList[i].coordinates == new_c):
			new_i = i
			break
	
	currentRoom = roomList[new_i]
	if event == 0:
		minimap.changeTexture(new_i)
	locPin.position = locPinStartPos - currentRoom.coordinates * minimap.space
	print(locPin.position)
	print(currentRoom.coordinates)
	doomBar.value += 1
	doomBarValue.text = str(doomBar.value)
	emit_signal("change_room",new_i)
