extends Node3D
#---------------------------------------------------------------------------------
# Gère le fonctionnement de la salle en cours, ainsi que son changement.
#---------------------------------------------------------------------------------
var wallTextList = ["res://Images/ComfyUI_WallSpider.png","res://Images//Photo_moi.JPG","res://Images//_Wall0.png"] # Liste des textures possibles pour le mur.
var groundTextList = ["res://Images/Ground0.png","res://Images/Ground0.png"] # Liste des textures possibles pour le sol.
var ceilingTextList = ["res://Images//map3.jpg"]  # Liste des textures possibles pour le plafond.

# Liste des meshs
var wall1
var wall2
var wall3
var wall4
var ground
var ceiling

var childList
var textList

var mainUI
var minimap
var roomListNode
var roomList
var keyNumber
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
	room_init(0)

# Applique les textures aux surfaces, identifie la salle actuelle et active les menus de jeu.
func room_init(id : int) -> void:
	print("nouvelle salle")
	currentRoom = roomList[id]
	var s = wallTextList.size()
	wall1 = wallTextList[randi() % s]
	wall2 = wallTextList[randi() % s]
	wall3 = wallTextList[randi() % s]
	wall4 = wallTextList[randi() % s]
	ceiling = ceilingTextList[randi() % ceilingTextList.size()]
	ground = groundTextList[randi() % groundTextList.size()]
	textList = [wall1, wall2, wall3, wall4, ceiling, ground]
	for i in range(6):
		apply_texture(i)
	mainUI.hide()
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
					if typeQuestion < 25 :
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
					if typeEvent < 30 :
						reTP.show()
						var newRoom = roomList[randi() % roomListNode.roomNumber].coordinates
						#print(newRoom)
						await get_tree().create_timer(1.5).timeout
						reTP.hide()
						mainUI.FindNextRoom(1,newRoom)
						mainUI.ShowButtons()
					# +5 de malédiction
					elif typeEvent < 50 :
						mainUI.doomBar.value += 5
						mainUI.doomBarValue.text = str(mainUI.doomBar.value)
						reWDoom.show()
						await get_tree().create_timer(1.5).timeout
						reWDoom.hide()
						mainUI.show()
					# -5 de malédiction
					elif typeEvent < 70 :
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
