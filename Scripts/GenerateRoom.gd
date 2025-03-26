extends Node3D
#---------------------------------------------------------------------------------
# Gère le fonctionnement de la salle en cours, ainsi que son changement.
#---------------------------------------------------------------------------------
var wallList = ["mansion1","mansion2","wallpaper","white_brick"] # Liste des textures possibles pour le mur.
var wallTextList = []
var groundList = ["Ground"] # Liste des textures possibles pour le sol.
var groundTextList = []
var ceilingList = ["Ceiling"]  # Liste des textures possibles pour le plafond.
var ceilingTextList = []

# Liste des meshs
var wall1
var wall2
var wall3
var wall4
var ground
var ceiling
#var propPreload = preload("res://Classes/PropData.tscn") # C'est la "classe" salle qu'on va pouvoir instancier.
var woodenTable
var woodenChair

var childList
var textList

var mainUI
var minimap
var roomListNode
var roomList
var keyNumber
var commentaryPanel
var commentaryText
var inventory
var inventoryNone
var qcm
var qopen
var reMenu
var reTP
var reWDoom
var reLDoom
var keyMenu
var curseMenu
var winMenu
var loseMenu

var currentRoom
var numberOfKeys = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	childList = [$Mur1, $Mur2, $Mur3, $Mur4, $Plafond, $Sol]
	
	mainUI = $MainUI
	minimap = $MainUI/Minimap
	roomListNode = $MainUI/Minimap/RoomList
	roomList = roomListNode.roomList
	keyNumber = $MainUI/KeyValue
	commentaryPanel = $MainUI/CommentaryPanel
	commentaryText = $MainUI/CommentaryPanel/TextEdit
	inventory = $Inventaire
	inventoryNone = $Inventaire/Obj_None
	qcm = $QCM_Menu
	qopen = $Enigme_Menu
	reMenu = $RandomEvent_Menu
	reTP = $RE_TP
	reWDoom = $RE_WinDoom
	reLDoom = $RE_LoseDoom
	keyMenu = $KeyRoom_Menu
	curseMenu = $CurseRoom_Menu
	winMenu = $Win_Menu
	loseMenu = $Lose_Menu
	woodenTable = $WoodenTable
	woodenChair = $WoodenChair
	for i in range(wallList.size()):
		wallTextList.append("res://Output/Walls/"+wallList[i]+".png")
		for j in range(4):
			wallTextList.append("res://Output/Walls/"+wallList[i]+"_"+str(j)+".png")
	for i in range(groundList.size()):
		for j in range(6):
			groundTextList.append("res://Output/Grounds/"+groundList[i]+str(j)+".png")
	for i in range(ceilingList.size()):
		for j in range(4):
			ceilingTextList.append("res://Output/Ceilings/"+ceilingList[i]+str(j)+".png")
	room_init(0)
	
	print(wallTextList)
	#var newProp = propPreload.instantiate()
	#newProp.setup(0, 0)
	#add_child(newProp)
	#var coordinates = Vector3(randf_range(-1.5,1.5),-2,randf_range(-1.5,1.5))
	#print(coordinates)
	#newProp.position = coordinates
	#print(newProp.position)

# Applique les textures aux surfaces, identifie la salle actuelle et active les menus de jeu.
func room_init(id : int) -> void:
	print("nouvelle salle")
	currentRoom = roomList[id]
	var t = randi() % wallTextList.size() / 5
	print(t)
	var s = 5
	wall1 = wallTextList[5*t + randi() % s]
	wall2 = wallTextList[5*t + randi() % s]
	wall3 = wallTextList[5*t + randi() % s]
	wall4 = wallTextList[5*t + randi() % s]
	ceiling = ceilingTextList[randi() % ceilingTextList.size()]
	ground = groundTextList[randi() % groundTextList.size()]
	textList = [wall1, wall2, wall3, wall4, ceiling, ground]
	for i in range(6):
		apply_texture(i)
	
	woodenTable.position = Vector3(randf_range(-10,10),-2,randf_range(-10,10))
	woodenTable.rotation = Vector3(0,randf_range(-90,90),0)
	woodenChair.position = Vector3(randf_range(-10,10),-2,randf_range(-10,10))
	woodenChair.rotation = Vector3(0,randf_range(-90,90),0)
	mainUI.hide()
	commentaryPanel.hide()
	commentaryText.text = ""
	inventory.show()
	inventoryNone.grab_focus()

# Applique la texture choisie à la surface choisie
func apply_texture(id: int) -> void:
	var image = Image.new()
	image.load(textList[id])
	var tex = ImageTexture.create_from_image(image)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = tex
	childList[id].set_surface_override_material(0, mat)
	pass

# Capte le signal de changement de salle (voir Main_UI.gd).
func _on_main_ui_change_room(id : int) -> void:
	room_init(id)

# Capte le signal de fin de la phase d'objet (voir Inventaire.gd), puis applique l'effet de la salle en fonction de son type (voir Room.gd). Vérifie si la partie est terminée.
func _on_inventaire_obj_done() -> void:
	currentRoom.isRevealed = true
	RevealCurrentRoom()
	# Si la malédiction est arrivée au bout [DÉFAITE].
	if mainUI.doomBar.value >= 100:
		loseMenu.show()
	# Sinon, on regarde la salle courante.
	else :
		match currentRoom.typeRoom:
			-3: # Salle à clef
				# Si la clef n'a pas été récupérée.
				if currentRoom.extraData == 0:
					keyMenu.show()
					await get_tree().create_timer(1.5).timeout
					keyMenu.hide()
					numberOfKeys += 1
					currentRoom.extraData = 1 # Note la salle comme explorée.
					keyNumber.text = str(numberOfKeys) + "/3"
					mainUI.show()
				# Sinon, on ne fait rien.
				else :
					mainUI.show()
			-2: # Salle maudite
				# Si les 3 clef sont réunies, termine le jeu. À terme avec un multijoueur, leur demande de démasquer le traître pour gagner (sinon téléportation au début).
				if numberOfKeys >= 3:
					winMenu.show()
				# Sinon, on indique au joueur qu'il manque des clef.
				else :
					curseMenu.show()
					await get_tree().create_timer(3).timeout
					curseMenu.hide()
					mainUI.show()
			0: # Salle à énigme/QCM
				if inventory.freeQuestion == 0 :
					await get_tree().create_timer(1.0).timeout
					var typeQuestion = randi() % 100
					# Énigme ouverte
					if typeQuestion < 100 :
						qopen.show()
					# QCM (préférable pour la majorité car plus simple)
					else :
						qcm.show()
				else :
					inventory.freeQuestion -= 1
					mainUI.show()
			1: # Salle à événement
				if inventory.freeEvent == 0 :
					reMenu.show()
					await get_tree().create_timer(2.0).timeout
					reMenu.hide()
					var typeEvent = randi() % 100
					# Téléportation aléatoire
					if typeEvent < 35 :
						reTP.show()
						var newRoom = roomList[randi() % roomListNode.roomNumber].coordinates
						#print(newRoom)
						await get_tree().create_timer(1.5).timeout
						reTP.hide()
						mainUI.FindNextRoom(1,newRoom)
						mainUI.ShowButtons()
					# +5 de malédiction
					elif typeEvent < 70 :
						mainUI.doomBar.value += 5
						mainUI.doomBarValue.text = str(mainUI.doomBar.value)
						reWDoom.show()
						await get_tree().create_timer(1.5).timeout
						reWDoom.hide()
						mainUI.show()
					# -5 de malédiction
					elif typeEvent < 90 :
						mainUI.doomBar.value -= 5
						mainUI.doomBarValue.text = str(mainUI.doomBar.value)
						reLDoom.show()
						await get_tree().create_timer(1.5).timeout
						reLDoom.hide()
						mainUI.show()
					# RIEN (peut arriver)
					else :
						mainUI.show()
				else :
					inventory.freeEvent -= 1
					mainUI.show()
			_: # Cas général (si une salle n'est pas programmée)
				mainUI.show()

# Révèle la salle actuelle sur la minimap.
func RevealCurrentRoom() -> void:
	for i in range(roomList.size()):
		if roomList[i].coordinates == currentRoom.coordinates :
			minimap.changeTexture(i)
